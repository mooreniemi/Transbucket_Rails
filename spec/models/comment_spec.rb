require 'spec_helper'

describe Comment, '#new_as_of' do
  let!(:comment) { create(:comment) }
  it 'ignores comments created since sign in' do
    last_sign_in = Time.now
    expect(Comment.new_as_of(last_sign_in)).to eq([])
  end
  it 'finds all comments new to a user since their last login' do
    last_sign_in = Time.now - 1.day
    expect(Comment.new_as_of(last_sign_in)).to match_array(Comment.all)
  end
  it 'can be chained with query on specific pin' do
    last_sign_in = Time.now - 1.day
    comments = Comment.new_as_of(last_sign_in)
    expect(comments.where(commentable_id: comment.commentable.id)).
      to match_array(Comment.last)
  end
end
