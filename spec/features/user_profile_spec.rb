require "rails_helper"

# truncation strategy is required because emails are sent in transaction hook
RSpec.describe "user profile", truncation: true do
  let!(:genders) { create_list(:gender, 5) }
  let(:user) { create(:user, :with_confirmation, :wants_notifications, gender: genders.last) }
  let!(:updated) { build(:user) }

  before(:each) do
    login_as(user, :scope => :user)
    visit '/users/edit'
  end

  after :each do
    Warden.test_reset!
  end

  it "shows the correct user info and gender" do
    expect(find("#user_name").value).to eq(user.name)
    expect(find("#user_username").value).to eq(user.username)
    expect(find("#user_gender_id").value.to_i).to eq(user.gender.id)
    expect(find("#user_email").value).to eq(user.email)
    expect(find("#user_current_password").value).to eq(nil)
  end

  it "updates the user's profile info with a valid password" do
    within("#edit_user") do
      fill_in "user_name", :with => updated.name
      fill_in "user_username", :with => updated.username
      select updated.gender.name, :from => "user_gender_id"

      fill_in "user_current_password", :with => user.password
      click_button "Update"
    end

    expect(page).to have_content("You updated your account successfully")

    db_user = User.find(user.id)
    expect(db_user.name).to eq(updated.name)
    expect(db_user.username).to eq(updated.username)
    expect(db_user.gender.id).to eq(updated.gender.id)
  end

  it "updates password if new password valid" do
    within("#edit_user") do
      fill_in "user_password", :with => updated.password
      fill_in "user_password_confirmation", :with => updated.password
      fill_in "user_current_password", :with => user.password
      click_button "Update"
    end

    expect(page).to have_content("You updated your account successfully")

    db_user = User.find(user.id)
    expect(db_user.valid_password?(user.password)).to be false
    expect(db_user.valid_password?(updated.password)).to be true
  end

  it "updates email only after reconfirming at the new address" do
    clear_emails

    within("#edit_user") do
      fill_in "user_email", :with => updated.email
      fill_in "user_current_password", :with => user.password
      click_button "Update"
    end

    expect(page).to have_content("need to verify your new email address")

    db_user = User.find(user.id)
    expect(db_user.pending_reconfirmation?).to be true
    expect(db_user.email).to eq(user.email)
    expect(db_user.unconfirmed_email).to eq(updated.email)

    open_email(updated.email)

    current_email.click_link "Confirm my account"

    db_user = User.find(user.id)
    expect(db_user.email).to eq(updated.email)
  end

  it "displays errors on invalid input" do
    within("#edit_user") do
      fill_in "user_email", :with => "!%"
      fill_in "user_current_password", :with => user.password
      click_button "Update"
    end
    expect(page).to have_content("Email is invalid")
  end
end
