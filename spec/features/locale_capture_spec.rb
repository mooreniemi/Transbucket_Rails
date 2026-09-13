require 'rails_helper'

describe 'capturing a signed-in user\'s locale' do
  it 'persists the resolved locale onto the user record when it changes' do
    user = create(:user, :with_confirmation, locale: nil)
    login_as(user, scope: :user)

    visit '/de/about'

    expect(user.reload.locale).to eq('de')
  end

  it 'does not touch the record when the locale already matches' do
    user = create(:user, :with_confirmation, locale: 'en')
    login_as(user, scope: :user)

    expect { visit '/en/about' }.not_to change { user.reload.locale }
  end

  it 'does not error for signed-out visitors' do
    expect { visit '/de/about' }.not_to raise_error
  end
end
