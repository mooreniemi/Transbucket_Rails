require 'spec_helper'

describe Flag do
  it '3 flags should make a pin pending' do
    pin = create(:pin)

    user = build_stubbed(:user)
    user2 = build_stubbed(:user)
    user3 = build_stubbed(:user)

    Flag.new(user, pin).flag_on
    Flag.new(user2, pin).flag_on
    Flag.new(user3, pin).flag_on

    expect(pin.pending?).to eq(true)
  end

  it '3 flags should make a comment pending' do
    comment = create(:comment)
    allow_any_instance_of(Pin).to receive(:user).and_return(create(:user))

    user = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    Flag.new(user, comment).flag_on
    Flag.new(user2, comment).flag_on
    Flag.new(user3, comment).flag_on

    expect(comment.pending?).to eq(true)
  end

  it "comment's parent pin author can send directly to pending" do
    pin_author = create(:user)
    pin = create(:pin, user: pin_author)
    comment_author = create(:user)
    comment = create(:comment, commentable_id: pin.id, user: comment_author)

    Flag.new(pin_author, comment).flag_on
    expect(comment.pending?).to eq(true)
  end
end
