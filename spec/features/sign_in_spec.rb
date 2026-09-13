require 'rails_helper'

describe "the sign-in process" do
  let!(:user) { create(:user, :with_confirmation) }

  around do |example|
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = original
  end

  def signin_with(username)
    visit '/users/sign_in'
    within("#new_user") do
      fill_in 'Username or email', :with => username
      fill_in 'Password', :with => user.password
    end
    click_button I18n.t('account_menu.login', locale: :en)
    expect(page).to have_content 'Signed in successfully'
  end

  it "should allow a user to sign in by username" do
    signin_with user.username
  end

  it "should allow a user to sign in by email" do
    signin_with user.email
  end

  it "accepts valid credentials with real CSRF protection enabled" do
    visit '/users/sign_in'
    within("#new_user") do
      fill_in 'Username or email', :with => user.username
      fill_in 'Password', :with => user.password
    end

    click_button I18n.t('account_menu.login', locale: :en)

    expect(page).to have_current_path(%r{/#{I18n.locale}/pins})
    expect(page).to have_content(I18n.t('devise.sessions.signed_in', locale: :en))
    expect(page).to have_content(I18n.t('account_menu.logout', locale: :en))
  end
end
