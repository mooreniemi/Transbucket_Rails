require 'rails_helper'

describe "the confirmation process" do
  it "signs the user in immediately after confirming, instead of requiring a separate login" do
    user = create(:user)

    visit "/users/confirmation?confirmation_token=#{user.confirmation_token}"

    expect(page).to have_content I18n.t('devise.confirmations.confirmed', locale: :en)
    expect(page).to have_link I18n.t('account_menu.logout', locale: :en)
  end

  it "sends an already-confirmed user to sign in rather than erroring" do
    user = create(:user, :with_confirmation)

    visit "/users/confirmation?confirmation_token=invalid-or-used-token"

    expect(page).not_to have_link I18n.t('account_menu.logout', locale: :en)
  end
end
