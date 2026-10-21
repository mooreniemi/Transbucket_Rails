require 'rails_helper'

# The React forgot password page (react/src/routes/$locale/_public/forgot-password.tsx)
# posts { user: { email } } as JSON. The reset link in the email still opens
# Devise's server-rendered page at /reset-password.
#
# Posted directly rather than driven in Capybara: the page is a Vite bundle,
# which isn't built under specs.
RSpec.describe 'password reset', type: :request do
  let!(:user) { create(:user, :with_confirmation) }

  def request_reset(email)
    post '/en/users/password', as: :json, params: { user: { email: email } }
  end

  it 'serves the React page, and sends the old URL there' do
    get '/en/forgot-password'
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

    new_password = 'a-brand-new-password'
    put '/en/users/password', params: {
      user: { reset_password_token: token, password: new_password, password_confirmation: new_password }
    }
    expect(user.reload.valid_password?(new_password)).to be true
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

  it 'answers 422 with an error code for a blank email' do
    request_reset('')

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body).to eq('errors' => { 'email' => [{ 'code' => 'blank' }] })
  end

  it 'redirects the old reset URL, keeping the token' do
    get '/es/users/password/edit?reset_password_token=abc&utm_medium=email'
    expect(response).to redirect_to('/es/reset-password?reset_password_token=abc&utm_medium=email')
  end
end
