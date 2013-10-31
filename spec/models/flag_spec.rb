require 'spec_helper'

describe Flag do
  it '3 flags should make a pin pending' do
    pin = FactoryGirl.create(:pin)

    user = FactoryGirl.build_stubbed(:user)
    user2 = FactoryGirl.build_stubbed(:user)
    user3 = FactoryGirl.build_stubbed(:user)

    flag = Flag.new(user, pin).flag_on
    flag2 = Flag.new(user2, pin).flag_on
    flag3 = Flag.new(user3, pin).flag_on

    expect(pin.pending?).to be(true)
  end

  it '3 flags should make a comment pending' do
    comment = FactoryGirl.create(:comment)

    user = FactoryGirl.build_stubbed(:user)
    user2 = FactoryGirl.build_stubbed(:user)
    user3 = FactoryGirl.build_stubbed(:user)

    flag = Flag.new(user, comment).flag_on
    flag2 = Flag.new(user2, comment).flag_on
    flag3 = Flag.new(user3, comment).flag_on

    expect(comment.pending?).to be(true)
  end
end
