require 'rails_helper'

# A standalone discussion's card in the feed reads like the other discussion
# cards: its title as the topic (the whole card opens it), its category and
# audience, who posted it and when, the opening of the post, and the same
# footer (Delete for its author, the reply count and Reply).
describe PinsController, type: :controller do
  render_views

  let(:viewer) { create(:user) }
  let(:author) { create(:user, username: 'discussion_author') }

  before { sign_in(viewer) }

  def card_for(discussion)
    Nokogiri::HTML(response.body).at_css(".feed-discussion[data-feed-key='discussion-#{discussion.id}']")
  end

  it 'leads with the title as the topic, then category, author and the opening of the post' do
    discussion = create(:discussion, user: author, title: 'Recovery questions', category: 'recovery',
                        body: (1..60).map { |i| "word#{i}" }.join(' '))

    get :index, params: { locale: 'en' }

    card = card_for(discussion)
    topic = card.at_css('.feed-discussion-topic a.feed-discussion-link')
    expect(topic.text.squish).to eq('Recovery questions')
    expect(topic['href']).to eq(discussion_path(discussion, locale: 'en'))
    expect(card.at_css('.discussion-category-chip').text.squish).to eq('Recovery')
    expect(card.at_css('.comment-author').text.squish).to eq('discussion_author')
    excerpt = card.at_css('.feed-discussion-excerpt')
    expect(excerpt.text).to include('word40')
    expect(excerpt.text).not_to include('word41')
    expect(excerpt.at_css('a.feed-discussion-more')['href']).to eq(discussion_path(discussion, locale: 'en'))
  end

  it 'badges a members-only discussion with its audience' do
    viewer.grant_trust!('contributor')
    discussion = create(:discussion, user: author, visibility: 'contributors')

    get :index, params: { locale: 'en' }

    expect(card_for(discussion).at_css('.audience-badge').text.squish).to eq('People who have posted a submission')
  end

  it 'counts replies and offers Reply, which goes to the reply box' do
    discussion = create(:discussion, user: author)
    root = CommentService.new(discussion, viewer, 'First').tap(&:create).comment
    CommentService.new(discussion, author, 'Second', root.id).tap(&:create)

    get :index, params: { locale: 'en' }

    footer = card_for(discussion).at_css('.panel-footer')
    expect(footer.at_css('.feed-discussion-replies').text.squish).to eq('2 replies')
    expect(footer.at_css('a.feed-discussion-reply')['href']).to eq(discussion_path(discussion, locale: 'en', anchor: 'commentable'))
  end

  it 'offers Delete to its author only' do
    mine = create(:discussion, user: viewer)
    theirs = create(:discussion, user: author)

    get :index, params: { locale: 'en' }

    delete_link = card_for(mine).at_css('a.feed-discussion-delete')
    expect(delete_link['href']).to eq(discussion_path(mine, locale: 'en'))
    expect(delete_link['data-method']).to eq('delete')
    expect(card_for(theirs).at_css('a.feed-discussion-delete')).to be_nil
  end
end

describe DiscussionsController, type: :controller do
  render_views

  let(:author) { create(:user) }
  let!(:discussion) { create(:discussion, user: author) }

  it 'leaves the layout out for the phone viewer' do
    sign_in(create(:user))

    get :show, params: { id: discussion.id, locale: 'en', viewer: '1' }

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include('<html')
    expect(response.body).to include(discussion.title)
  end

  it 'lets its author delete it, with its replies' do
    CommentService.new(discussion, create(:user), 'A reply').tap(&:create)
    sign_in(author)

    delete :destroy, params: { id: discussion.id, locale: 'en' }, xhr: true

    expect(response).to have_http_status(:ok)
    expect(Discussion.exists?(discussion.id)).to eq(false)
    expect(Comment.where(commentable_type: 'Discussion', commentable_id: discussion.id)).to be_empty
  end

  it 'lets a moderator delete it' do
    sign_in(create(:user).tap { |u| u.grant_trust!('moderator') })

    delete :destroy, params: { id: discussion.id, locale: 'en' }, xhr: true

    expect(Discussion.exists?(discussion.id)).to eq(false)
  end

  it "doesn't let anyone else delete it" do
    sign_in(create(:user))

    expect { delete :destroy, params: { id: discussion.id, locale: 'en' }, xhr: true }.to raise_error(ActiveRecord::RecordNotFound)
    expect(Discussion.exists?(discussion.id)).to eq(true)
  end
end
