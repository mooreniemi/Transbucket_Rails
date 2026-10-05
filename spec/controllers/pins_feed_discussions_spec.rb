require 'rails_helper'

# How a discussion (a top-level comment on a procedure or surgeon) looks as a
# home-feed card, and the Content filter that mixes them in. Rendered through
# the real controller and views.
describe PinsController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:procedure) { create(:procedure, name: 'double incision') }

  before { sign_in(user) }

  def card_for(comment)
    Nokogiri::HTML(response.body).at_css(".feed-discussion[data-comment-id='#{comment.id}']")
  end

  def thread_path_for(comment)
    procedure_path(procedure, locale: 'en', anchor: "comment-#{comment.id}")
  end

  it 'leads with the topic, linked straight to that comment in its thread' do
    comment = Comment.create!(commentable: procedure, user: author, body: 'How long was recovery?')

    get :index, params: { locale: 'en' }

    card = card_for(comment)
    topic = card.at_css('.feed-discussion-topic a.feed-discussion-link')
    expect(topic.text.strip).to eq('double incision')
    expect(topic['href']).to eq(thread_path_for(comment))
    expect(card.css('.panel-body > *').first['class']).to include('feed-discussion-topic')
  end

  it 'carries a key the infinite scroll can de-duplicate on' do
    comment = Comment.create!(commentable: procedure, user: author, body: 'Keyed')

    get :index, params: { locale: 'en' }

    expect(card_for(comment)['data-feed-key']).to eq("comment-#{comment.id}")
  end

  it "shows the author's trust badge, as the thread does" do
    author.grant_trust!('contributor')
    comment = Comment.create!(commentable: procedure, user: author, body: 'Badge please')

    get :index, params: { locale: 'en' }

    expect(card_for(comment).at_css('.trust-badge')).to be_present
  end

  it 'shows only the first words of a long post, with a link to read the rest' do
    body = (1..80).map { |i| "word#{i}" }.join(' ')
    comment = Comment.create!(commentable: procedure, user: author, body: body)

    get :index, params: { locale: 'en' }

    excerpt = card_for(comment).at_css('.feed-discussion-excerpt')
    expect(excerpt.text).to include('word40')
    expect(excerpt.text).not_to include('word41')
    more = card_for(comment).at_css('a.feed-discussion-more')
    expect(more.text.strip).to eq('Read more')
    expect(more['href']).to eq(thread_path_for(comment))
  end

  it 'shows a short post in full with no read-more link' do
    comment = Comment.create!(commentable: procedure, user: author, body: 'Short and sweet.')

    get :index, params: { locale: 'en' }

    expect(card_for(comment).at_css('.feed-discussion-excerpt').text).to include('Short and sweet.')
    expect(card_for(comment).at_css('a.feed-discussion-more')).to be_nil
  end

  it 'has a footer like photo posts: reply count, Reply, and Report for other people' do
    comment = Comment.create!(commentable: procedure, user: author, body: 'Any advice?')
    2.times { |i| Comment.create!(commentable: procedure, user: user, body: "reply #{i}").move_to_child_of(comment.reload) }

    get :index, params: { locale: 'en' }

    footer = card_for(comment).at_css('.panel-footer')
    expect(footer.at_css('.feed-discussion-replies').text).to include('2 replies')
    reply = footer.at_css('a.feed-discussion-reply')
    expect(reply['href']).to eq(procedure_path(procedure, locale: 'en', reply_to: comment.id, anchor: "comment-#{comment.id}"))
    expect(footer.at_css("a.flag-comment[data-comment-id='#{comment.id}']")).to be_present
    expect(footer.at_css('a.feed-discussion-delete')).to be_nil
  end

  it "lets the author delete their own post from the feed instead of reporting it" do
    comment = Comment.create!(commentable: procedure, user: user, body: 'Mine')

    get :index, params: { locale: 'en' }

    footer = card_for(comment).at_css('.panel-footer')
    expect(footer.at_css('a.feed-discussion-delete')['href']).to eq(comment_path(comment, locale: 'en'))
    expect(footer.at_css('a.flag-comment')).to be_nil
  end

  it 'offers Content as one-tap choices instead of a dropdown, keeping the current one selected' do
    get :index, params: { locale: 'en', content: 'discussions' }

    doc = Nokogiri::HTML(response.body)
    expect(doc.at_css('select#content')).to be_nil
    # The filter form is rendered twice (navbar menu and page panel); check each.
    forms = doc.css('form#filter_dropdown')
    expect(forms).not_to be_empty
    forms.each do |form|
      radios = form.css('input[type=radio][name=content]')
      expect(radios.map { |r| r['value'] }).to eq(%w[all submissions discussions])
      expect(radios.find { |r| r['checked'] }['value']).to eq('discussions')
    end
  end
end
