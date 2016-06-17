require "rails_helper"

RSpec.describe "cancel user account" do
  let(:user) { create(:user, :with_confirmation, :wants_notifications) }

  before(:each) do
    login_as(user, :scope => :user)
    visit '/users/edit'
  end

  after :each do
    Warden.test_reset!
  end

  context "without js" do
    it "deletes the user's account without confirmation" do
      click_button "Cancel my account"

      expect(User.where(email: user.email)).not_to exist
    end
  end

  context "with js", :js => true do
    it "deletes the user's account after confirmation" do
      accept_confirm do
        click_button "Cancel my account"
      end

      expect(User.where(email: user.email)).not_to exist
    end

    it "doesn't delete the account if not confirmed" do
      dismiss_confirm do
        click_button "Cancel my account"
      end

      expect(User.where(email: user.email)).to exist
    end
  end
end
