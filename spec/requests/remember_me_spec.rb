require 'rails_helper'

# "Stay logged in" on the sign-in form (Devise :rememberable) has to survive
# both ways a session ends on its own: the browser dropping the session cookie
# when it closes, and the one-week idle timeout (:timeoutable, User).
describe 'staying signed in', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:password) { 'correct horse battery staple' }
  let!(:user) { create(:user, :with_confirmation, password: password, password_confirmation: password) }

  def sign_in(remember:)
    post '/en/users/sign_in', params: { user: { login: user.username, password: password, remember_me: remember ? '1' : '0' } }
    expect(response).to have_http_status(:redirect)
    expect(response.location).not_to include('sign_in')
  end

  def signed_in?
    get '/en/pins'
    response.status == 200
  end

  # What a browser keeps after it is closed and reopened: persistent cookies
  # only, not the session cookie.
  def close_browser
    cookies.delete('_transbucket_session')
  end

  it 'sets a long-lived remember cookie when the box is ticked' do
    sign_in(remember: true)

    remember_cookie = Array(response.headers['Set-Cookie']).join("\n").split("\n").find { |line| line.start_with?('remember_user_token=') }
    expect(remember_cookie).to be_present
    expect(remember_cookie).to match(/expires=/i)
  end

  it 'keeps you signed in after the browser is closed' do
    sign_in(remember: true)
    close_browser

    expect(signed_in?).to be(true)
  end

  it 'keeps you signed in after more than a week idle' do
    sign_in(remember: true)
    expect(signed_in?).to be(true)

    travel(8.days) do
      expect(signed_in?).to be(true)
    end
  end

  it 'keeps a session without the box ticked through a day away, but not a week' do
    sign_in(remember: false)

    travel(1.day) { expect(signed_in?).to be(true) }
    travel(8.days) { expect(signed_in?).to be(false) }
  end

  it 'keeps you signed in after the browser is closed and reopened a day later' do
    sign_in(remember: true)
    close_browser

    travel(1.day) do
      expect(signed_in?).to be(true)
    end
  end

  context 'with a second device' do
    # Two independent browsers (separate cookie jars) for the same account.
    def device
      open_session.tap do |session|
        session.host! 'www.example.com'
      end
    end

    def sign_in_on(session, remember:)
      session.post '/en/users/sign_in', params: { user: { login: user.username, password: password, remember_me: remember ? '1' : '0' } }
      expect(session.response.location).not_to include('sign_in')
    end

    def signed_in_on?(session)
      session.get '/en/pins'
      session.response.status == 200
    end

    it 'stays signed in on your phone when your laptop has been left for a day' do
      phone, laptop = device, device
      sign_in_on(phone, remember: true)
      sign_in_on(laptop, remember: false)

      travel(1.day) do
        expect(signed_in_on?(laptop)).to be(true)
        phone.cookies.delete('_transbucket_session')
        expect(signed_in_on?(phone)).to be(true)
      end
    end

    it 'still signs every device out when the password changes' do
      phone = device
      sign_in_on(phone, remember: true)

      user.reload.update_attributes!(password: 'a different long password', password_confirmation: 'a different long password')
      phone.cookies.delete('_transbucket_session')

      expect(signed_in_on?(phone)).to be(false)
    end
  end

  it 'does not keep you signed in after closing the browser when the box is not ticked' do
    sign_in(remember: false)
    close_browser

    expect(signed_in?).to be(false)
  end
end
