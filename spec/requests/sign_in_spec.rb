require 'rails_helper'

# The React login page (react/src/routes/$locale/_public/login.tsx) posts JSON
# to Devise with the CSRF token from the page's csrf-token meta tag in an
# X-CSRF-Token header (react/src/lib/api.ts). These specs do the same, with
# Rails' real forgery protection switched on, since the page is a Vite bundle
# that isn't built under specs.
describe "the sign-in process", type: :request do
  let!(:user) { create(:user, :with_confirmation) }
  let(:generic) { I18n.t('devise.failure.invalid', authentication_keys: 'email', locale: :en) }

  around do |example|
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = original
  end

  def csrf_token
    get '/en/login'
    response.body[/<meta name="csrf-token" content="([^"]+)"/, 1].tap { |token| expect(token).to be_present }
  end

  def sign_in_json(login, password: user.password, token: csrf_token)
    post '/en/users/sign_in',
      params: { user: { login: login, password: password, remember_me: '0' } },
      headers: { 'X-CSRF-Token' => token },
      as: :json
  end

  it "signs in by username and says where to go next" do
    sign_in_json user.username

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq('redirect_to' => '/en/pins')

    get '/en/pins'
    expect(response).to have_http_status(:success)
    expect(response.body).to include(I18n.t('account_menu.logout', locale: :en))
  end

  it "signs in by email" do
    sign_in_json user.email

    expect(response).to have_http_status(:ok)
  end

  it "rejects a post without the token" do
    csrf_token

    expect {
      post '/en/users/sign_in', params: { user: { login: user.username, password: user.password } }, as: :json
    }.to raise_error(ActionController::InvalidAuthenticityToken)
  end

  describe 'failures' do
    it 'answers 401 with the generic message for a wrong password' do
      sign_in_json user.username, password: 'not-it'

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body.fetch('errors')).to eq('base' => [generic])
    end

    it 'gives the same answer for an account that does not exist' do
      sign_in_json 'nobody_here', password: 'whatever-it-is'

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body.fetch('errors')).to eq('base' => [generic])
    end

    it 'does not reveal that an unconfirmed account exists' do
      unconfirmed = create(:user)

      sign_in_json unconfirmed.username, password: unconfirmed.password

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body.fetch('errors')).to eq('base' => [generic])
    end

    it 'uses the same generic message for plain HTML posts' do
      unconfirmed = create(:user)

      post '/en/users/sign_in', params: {
        authenticity_token: csrf_token,
        user: { login: unconfirmed.username, password: unconfirmed.password }
      }

      expect(flash[:alert]).to eq(generic)
    end
  end
end
