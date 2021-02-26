require "rails_helper"

RSpec.describe "password reset" do
  let!(:users) { create_list(:user, 2, :with_confirmation) }
  let!(:user) { users.last }

  it "sends an email with a reset token that works" do
    visit '/users/password/new'

    fill_in "Email", :with => user.email

    clear_emails
    click_button "Send me reset password instructions"
    open_email(user.email)

    expect(current_email).to have_content("Hello #{user.email}")

    current_email.click_link 'Change my password'

    new_password = Faker::Internet.password

    fill_in "New password", :with => new_password
    fill_in "Confirm new password", :with => new_password
    click_button "Change my password"

    expect(page).to have_content("Your password was changed successfully.")
    expect(User.find(user.id).valid_password?(new_password)).to be true
  end
end
