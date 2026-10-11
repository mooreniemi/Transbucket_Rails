require 'rails_helper'

RSpec.describe Comment do
  let(:author) { create(:user) }
  let(:procedure) { create(:procedure) }
  let(:surgeon) { create(:surgeon) }

  def comment_with(visibility, subject: procedure)
    create(:comment, commentable: subject, user: author, visibility: visibility)
  end

  it 'shows public discussions to signed-out viewers only' do
    public_comment = comment_with('everyone')
    contributor_comment = comment_with('contributors')

    expect(Comment.visible_to(nil)).to include(public_comment)
    expect(Comment.visible_to(nil)).not_to include(contributor_comment)
  end

  it 'shows contributor discussions to users with an active trust grant' do
    viewer = create(:user)
    viewer.grant_trust!('contributor')
    comment = comment_with('contributors')

    expect(Comment.visible_to(viewer)).to include(comment)
  end

  it 'shows subject-contributor discussions only to users with a published subject submission' do
    subject_contributor = create(:user)
    other_contributor = create(:user)
    create(:pin, user: subject_contributor, procedure: procedure, surgeon: surgeon)
    other_contributor.grant_trust!('contributor')
    comment = comment_with('subject_contributors')

    expect(Comment.visible_to(subject_contributor)).to include(comment)
    expect(Comment.visible_to(other_contributor)).not_to include(comment)
  end

  it 'inherits a root discussion visibility for replies' do
    root = comment_with('contributors')
    reply = CommentService.new(procedure, author, 'reply', root.id, 'everyone').tap(&:create).comment
    viewer = create(:user)

    expect(reply.visibility).to eq('contributors')
    expect(Comment.visible_to(viewer)).not_to include(reply)
  end
end
