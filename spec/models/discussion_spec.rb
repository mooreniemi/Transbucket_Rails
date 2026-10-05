require 'rails_helper'

RSpec.describe Discussion do
  it 'requires a title, body, and author' do
    discussion = described_class.new

    expect(discussion).not_to be_valid
    expect(discussion.errors).to include(:title, :body, :user)
  end

  it 'allows contributors-only posts to their author and trusted readers' do
    author = create(:user)
    viewer = create(:user)
    discussion = create(:discussion, user: author, visibility: 'contributors')

    expect(described_class.visible_to(nil)).not_to include(discussion)
    expect(described_class.visible_to(author)).to include(discussion)
    expect(described_class.visible_to(viewer)).not_to include(discussion)

    viewer.grant_trust!('contributor')
    expect(described_class.visible_to(viewer)).to include(discussion)
  end

  it 'supports replies through the existing comment model' do
    discussion = create(:discussion)
    reply = CommentService.new(discussion, create(:user), 'A reply').tap(&:create).comment

    expect(reply.commentable).to eq(discussion)
    expect(discussion.comments_asc.map(&:id)).to include(reply.id)
  end
end
