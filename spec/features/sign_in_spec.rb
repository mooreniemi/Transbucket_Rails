require 'rails_helper'

describe "the sign-in process" do
  let!(:user) { create(:user, :with_confirmation) }

  def signin_with(username)
    visit '/users/sign_in'
    within("#new_user") do
      fill_in 'Username', :with => username
      fill_in 'Password', :with => user.password
    end
    click_button 'Sign in'
    expect(page).to have_content 'Signed in successfully'
  end

  it "should allow a user to sign in by username" do
    signin_with user.username
  end

  it "should allow a user to sign in by email" do
    signin_with user.email
  end
end
