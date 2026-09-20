require 'rails_helper'

describe PreferencesController, type: :controller do
  describe 'PUT #update' do
    it 'requires sign-in' do
      user = create(:user)

      put :update, user_id: user.id, preference: { safe_mode: '1' }

      expect(response).to redirect_to(new_user_session_path(locale: nil))
      expect(Preference.find_by!(user_id: user.id).safe_mode).to eq(false)
    end

    it 'updates the signed-in user preference' do
      user = create(:user)
      sign_in(user)

      put :update, user_id: user.id, preference: { safe_mode: '1', notification: '0' }

      expect(response).to redirect_to(edit_user_registration_path)
      preference = Preference.find_by!(user_id: user.id)
      expect(preference.safe_mode).to eq(true)
      expect(preference.notification).to eq(false)
    end

    it 'does not let a signed-in user update another user preference via the URL' do
      user = create(:user)
      other_user = create(:user)
      sign_in(user)

      put :update, user_id: other_user.id, preference: { safe_mode: '1' }

      expect(Preference.find_by!(user_id: user.id).safe_mode).to eq(true)
      expect(Preference.find_by!(user_id: other_user.id).safe_mode).to eq(false)
    end
  end

  describe 'PATCH #update from the header safe mode switch' do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it 'sends people back to the page they were on' do
      patch :update, user_id: user.id, preference: { safe_mode: '1' }, return_to: '/en/pins?page=2'

      expect(response).to redirect_to('/en/pins?page=2')
      expect(Preference.find_by!(user_id: user.id).safe_mode).to eq(true)
    end

    it 'ignores return_to values that would leave the site' do
      ['http://evil.example/', '//evil.example/', '/\\evil.example', 'javascript:alert(1)', '/ok path'].each do |bad|
        patch :update, user_id: user.id, preference: { safe_mode: '0' }, return_to: bad

        expect(response).to redirect_to(edit_user_registration_path)
      end
    end
  end
end
