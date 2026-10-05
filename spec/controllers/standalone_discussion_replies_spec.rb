require 'rails_helper'

# Replying to a standalone discussion (/discussions/:id): only people who can
# read it can reply, a reply can't be slipped under a thread you can't read,
# and its author's email links back to the discussion.
describe CommentsController, type: :controller do
  let(:author) { create(:user) }
  let(:viewer) { create(:user) }
  let(:members_only) { create(:discussion, user: author, visibility: 'contributors') }

  before { sign_in(viewer) }

  def reply(to:, parent: nil, body: 'Me too')
    post :create, params: {
      locale: 'en',
      comment: { commentable_type: to.class.name, commentable_id: to.id, parent_id: parent&.id, body: body }
    }
  end

  it "won't take a reply on a discussion you can't read" do
    expect { reply(to: members_only) }.to raise_error(ActiveRecord::RecordNotFound)
    expect(Comment.where(commentable: members_only)).to be_empty
  end

  it "won't take a reply under a restricted thread you can't read" do
    procedure = create(:procedure, name: 'phalloplasty')
    root = CommentService.new(procedure, author, 'Only for people who posted', nil, 'subject_contributors').tap(&:create).comment

    expect { reply(to: procedure, parent: root) }.to raise_error(ActiveRecord::RecordNotFound)
    expect(root.reload.children).to be_empty
  end

  it "won't hang a reply under a comment from somewhere else" do
    open_discussion = create(:discussion, user: author)
    elsewhere = CommentService.new(create(:procedure), author, 'Elsewhere').tap(&:create).comment

    expect { reply(to: open_discussion, parent: elsewhere) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'takes a reply on a discussion you can read' do
    open_discussion = create(:discussion, user: author)

    reply(to: open_discussion)

    expect(response).to have_http_status(:created)
    expect(Comment.where(commentable: open_discussion).count).to eq(1)
  end

  it 'emails the author a link to the discussion, not to a submission' do
    open_discussion = create(:discussion, user: author)

    expect { reply(to: open_discussion) }.to change { ActionMailer::Base.deliveries.size }.by(1)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.body.encoded).to include("/en/discussions/#{open_discussion.id}")
    expect(mail.body.encoded).not_to include("/en/pins/#{open_discussion.id}")
  end
end

describe CommentsController, type: :controller do
  render_views

  it 'offers no audience choice on a reply to a standalone discussion (the discussion sets it)' do
    sign_in(create(:user))
    discussion = create(:discussion)

    get :new, params: { commentable_id: discussion.id, commentable_type: 'Discussion', locale: 'en' }, xhr: true, format: :js

    expect(response.body).not_to include('comment[visibility]')
  end
end

describe Discussion, type: :model do
  it 'shows members-only discussions to moderators, as restricted comments are' do
    moderator = create(:user).tap { |u| u.grant_trust!('moderator') }
    members_only = create(:discussion, visibility: 'contributors')

    expect(Discussion.visible_to(moderator)).to include(members_only)
  end
end
