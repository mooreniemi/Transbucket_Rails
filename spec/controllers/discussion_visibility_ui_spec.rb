require 'rails_helper'

# What people see of restricted discussions: a locked stub for threads they
# can't read (so they know they exist and how to join), a lock badge naming
# the audience on threads they can read, and plain one-tap audience choices
# when starting a discussion.
module DiscussionVisibilityUi
  def doc
    @docs ||= {}
    @docs[response.body] ||= Nokogiri::HTML(response.body)
  end

  def restricted_thread(on:, by:, visibility: 'subject_contributors', replies: 0)
    root = CommentService.new(on, by, 'Secret recovery notes', nil, visibility).tap(&:create).comment
    replies.times { |i| CommentService.new(on, by, "reply #{i}", root.id).tap(&:create) }
    root.reload
  end
end

describe ProceduresController, type: :controller do
  include DiscussionVisibilityUi
  render_views

  let(:viewer) { create(:user) }
  let(:author) { create(:user, username: 'thread_author') }
  let(:phalloplasty) { create(:procedure, name: 'phalloplasty') }

  before { sign_in(viewer) }

  it "shows a locked stub for a thread you can't read: its audience and size, not its words or author" do
    restricted_thread(on: phalloplasty, by: author, replies: 2)

    get :show, params: { id: phalloplasty.id, locale: 'en' }

    stub = doc.at_css('section#discussion .locked-discussion')
    expect(stub.text.squish).to include('A discussion for people who posted about phalloplasty')
    expect(stub.text.squish).to include('2 replies')
    expect(stub.text).not_to include('Secret recovery notes')
    expect(stub.text).not_to include('thread_author')
    join = stub.at_css('a.locked-discussion-join')
    expect(join.text.squish).to eq('Share your experience to join')
    expect(join['href']).to eq(new_pin_path(locale: 'en'))
  end

  it 'labels a thread for anyone who has posted a submission' do
    restricted_thread(on: phalloplasty, by: author, visibility: 'contributors')

    get :show, params: { id: phalloplasty.id, locale: 'en' }

    expect(doc.at_css('.locked-discussion').text.squish).to include('A discussion for people who have posted a submission')
  end

  it 'counts locked threads in the jump link, matching what the section lists' do
    CommentService.new(phalloplasty, author, 'Open to all', nil, 'everyone').tap(&:create)
    restricted_thread(on: phalloplasty, by: author, replies: 2)

    get :show, params: { id: phalloplasty.id, locale: 'en' }

    expect(doc.at_css('a.discussion-jump').text.squish).to eq('Discussion (4)')
  end

  it 'badges a restricted thread you can read with its audience, and shows no stub for it' do
    create(:pin, user: viewer, procedure: phalloplasty)
    root = restricted_thread(on: phalloplasty, by: author)

    get :show, params: { id: phalloplasty.id, locale: 'en' }

    badge = doc.at_css("#comment-#{root.id} .audience-badge")
    expect(badge.text.squish).to eq('People who posted about phalloplasty')
    expect(doc.at_css('.locked-discussion')).to be_nil
  end
end

describe PinsController, type: :controller do
  include DiscussionVisibilityUi
  render_views

  it 'badges a restricted discussion card in the feed with its audience' do
    viewer = create(:user)
    phalloplasty = create(:procedure, name: 'phalloplasty')
    create(:pin, user: viewer, procedure: phalloplasty)
    root = restricted_thread(on: phalloplasty, by: create(:user))
    sign_in(viewer)

    get :index, params: { locale: 'en' }

    badge = doc.at_css(".feed-discussion[data-comment-id='#{root.id}'] .audience-badge")
    expect(badge.text.squish).to eq('People who posted about phalloplasty')
  end
end

describe CommentsController, type: :controller do
  include DiscussionVisibilityUi
  render_views

  let(:viewer) { create(:user) }
  let(:phalloplasty) { create(:procedure, name: 'phalloplasty') }

  before { sign_in(viewer) }

  # comments/new responds with JavaScript that inserts the form.
  def form_html
    Nokogiri::HTML(response.body.gsub('\\"', '"').gsub('\\n', "\n").gsub('\\/', '/'))
  end

  it 'offers the audience as one-tap choices in plain words when starting a discussion' do
    get :new, params: { commentable_id: phalloplasty.id, commentable_type: 'Procedure', locale: 'en' }, xhr: true, format: :js

    choices = form_html.css('.comment-audience input[type=radio][name="comment[visibility]"]')
    expect(choices.map { |input| input['value'] }).to eq(%w[everyone contributors subject_contributors])
    expect(choices.find { |input| input['checked'] }['value']).to eq('everyone')
    labels = form_html.css('.comment-audience label').map { |label| label.text.squish }
    expect(labels).to eq(['Everyone', 'People who have posted a submission', 'People who posted about phalloplasty'])
    expect(form_html.at_css('select#comment_visibility')).to be_nil
  end

  it 'badges a restricted discussion on its own page' do
    create(:pin, user: viewer, procedure: phalloplasty)
    root = restricted_thread(on: phalloplasty, by: create(:user))

    get :show, params: { id: root.id, locale: 'en' }

    expect(doc.at_css("#comment-#{root.id} .audience-badge").text.squish).to eq('People who posted about phalloplasty')
  end
end
