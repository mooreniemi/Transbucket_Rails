require 'rails_helper'

# The React forgot password page (react/src/routes/$locale/_public/forgot-password.tsx)
# posts { user: { email } } as JSON. The email links to the React reset page
# (reset-password.tsx), which PUTs the token and the new password as JSON.
#
# Posted directly rather than driven in Capybara: the page is a Vite bundle,
# which isn't built under specs.
RSpec.describe 'password reset', type: :request do
  let!(:user) { create(:user, :with_confirmation) }

  def request_reset(email)
    post '/en/users/password', as: :json, params: { user: { email: email } }
  end

  def change_password(token, password, confirmation = password)
    put '/en/users/password', as: :json, params: {
      user: { reset_password_token: token, password: password, password_confirmation: confirmation }
    }
  end

  it 'serves the React pages, and sends the old forgot password URL there' do
    get '/en/forgot-password'
    expect(response).to have_http_status(:ok)

    get '/en/reset-password'
    expect(response).to have_http_status(:ok)

    get '/en/users/password/new'
    expect(response).to redirect_to('/en/forgot-password')
  end

  it 'emails a link that resets the password' do
    ActionMailer::Base.deliveries.clear
    request_reset(user.email)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include('redirect_to' => '/en/login')

    link = ActionMailer::Base.deliveries.last.body.to_s[/href="([^"]*reset_password_token=[^"]*)"/, 1]
    expect(link).to include('/en/reset-password?')
    token = CGI.unescapeHTML(link)[/reset_password_token=([^&]+)/, 1]

    get "/en/reset-password?reset_password_token=#{token}"
    expect(response).to have_http_status(:ok)

    change_password(token, 'a-brand-new-password')

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(
      'message' => I18n.t('devise.passwords.updated'),
      'redirect_to' => '/en/pins'
    )
    expect(user.reload.valid_password?('a-brand-new-password')).to be true
  end

  describe 'changing the password' do
    let!(:token) { user.send_reset_password_instructions }

    it 'signs the user in' do
      change_password(token, 'a-brand-new-password')

      get '/en/login'
      expect(response).to have_http_status(:redirect)
    end

    it 'answers 422 with a code on the token for a wrong token' do
      change_password('not-the-token', 'a-brand-new-password')

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['errors']).to eq('reset_password_token' => [{ 'code' => 'invalid' }])
    end

    it 'answers 422 with a code on the token for an expired link' do
      user.update_column(:reset_password_sent_at, 7.hours.ago)
      change_password(token, 'a-brand-new-password')

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['errors']).to eq('reset_password_token' => [{ 'code' => 'expired' }])
    end

    it 'answers 422 with codes for a short or mismatched password, and keeps the old one' do
      change_password(token, 'short', 'different')

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['errors']).to eq(
        'password' => [{ 'code' => 'too_short', 'count' => 8 }],
        'password_confirmation' => [{ 'code' => 'confirmation' }]
      )
      expect(user.reload.valid_password?('short')).to be false
    end

    it 'never sends the password back' do
      change_password(token, 'a-brand-new-password')

      expect(response.body).not_to include('a-brand-new-password')
      expect(response.body).not_to include(token)
    end
  end

  it 'gives the same answer for an email with no account, and sends nothing' do
    request_reset(user.email)
    known = response.parsed_body

    ActionMailer::Base.deliveries.clear
    request_reset('nobody@example.com')

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(known)
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it 'gives the same answer for a blank email' do
    request_reset(user.email)
    known = response.parsed_body

    request_reset('')

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(known)
  end

  # Devise is paranoid, so a plain form post (not the React page's JSON)
  # doesn't give it away either.
  it 'does not say whether the email exists to a plain form post' do
    post '/en/users/password', params: { user: { email: 'nobody@example.com' } }

    expect(response).to redirect_to('/en/users/sign_in')
    expect(flash[:notice]).to eq(I18n.t('devise.passwords.send_paranoid_instructions'))
  end

  it 'redirects the old reset URL, keeping the token' do
    get '/es/users/password/edit?reset_password_token=abc&utm_medium=email'
    expect(response).to redirect_to('/es/reset-password?reset_password_token=abc&utm_medium=email')
  end
end
