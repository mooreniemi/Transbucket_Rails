require 'rails_helper'

# Opening the login page when you're already signed in (an old bookmark, the
# back button) just takes you in. Nothing to tell you about it.
describe 'opening the login page while signed in', type: :request do
  let(:password) { 'correct horse battery staple' }
  let!(:user) { create(:user, :with_confirmation, password: password, password_confirmation: password) }

  it 'goes on without a "You are already signed in." message' do
    post '/en/users/sign_in', params: { user: { login: user.username, password: password } }
    follow_redirect!

    %w[/en/login /en/users/sign_in /es/login].each do |path|
      get path
      expect(response).to have_http_status(:redirect)
      expect(flash.to_hash).to be_empty, "#{path} set #{flash.to_hash.inspect}"
      follow_redirect!
      expect(response.body).not_to include('already signed in')
    end
  end
end
