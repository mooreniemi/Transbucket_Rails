require "rails_helper"

RSpec.describe "user settings" do
  let(:user) { create(:user, :with_confirmation, :wants_notifications) }
  let(:pin) { create(:pin, user: user) }
  let(:commenter) { create(:user, :with_confirmation) }

  before(:each) do
    login_as(user, :scope => :user)
    visit '/users/edit'
  end

  after :each do
    Warden.test_reset!
  end

  it "updates notification settings" do
    policy = UserPolicy.new(User.find_by(email: user.email))
    expect(policy.wants_email?).to be true

    within("#edit_preference_#{user.id}") do
      uncheck "preference_notification"
      click_button "Update"
    end

    policy = UserPolicy.new(User.find_by(email: user.email))
    expect(policy.wants_email?).to be false
  end
end
