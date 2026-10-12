require 'rails_helper'

# The React sign-up page (react/src/routes/$locale/_public/register.tsx) posts
# a Gender name rather than an id, plus the pronoun fields in the backend's
# shape. These pin down that contract and the email-confirmation flow after it.
#
# They post the form's parameters directly rather than driving the page in
# Capybara: the page is a Vite bundle, which isn't built under specs.
RSpec.describe 'React sign-up form', type: :request do
  let!(:gender) { Gender.create!(name: 'GenderQueer') }

  def sign_up(overrides = {})
    post '/en/users', as: :json, params: {
      user: {
        name: 'Pat Example', username: 'pat_example', email: 'pat@example.com',
        password: 'a-long-password', password_confirmation: 'a-long-password',
        gender: 'GenderQueer', pronouns: '', pronouns_custom: '', terms: '1'
      }.merge(overrides)
    }
  end

  it 'resolves the gender name to gender_id and leaves default pronouns NULL' do
    sign_up

    user = User.find_by!(email: 'pat@example.com')
    expect(user.gender).to eq(gender)
    expect(user.pronouns).to be_nil
  end

  it 'matches the gender name case-insensitively' do
    sign_up(gender: 'genderqueer')

    expect(User.find_by!(email: 'pat@example.com').gender).to eq(gender)
  end

  it 'stores a preset as picked' do
    sign_up(pronouns: 'she/her')

    expect(User.find_by!(email: 'pat@example.com').pronouns).to eq('she/her')
  end

  it 'reads custom pronouns from pronouns_custom' do
    sign_up(pronouns: 'custom', pronouns_custom: 'Xe / Xem')

    expect(User.find_by!(email: 'pat@example.com').pronouns).to eq('xe/xem')
  end

  it 'rejects a password confirmation that does not match' do
    sign_up(password_confirmation: 'something-else')

    expect(User.find_by(email: 'pat@example.com')).to be_nil
  end

  it 'does not create a user when the gender name is unknown' do
    sign_up(gender: 'NotAGender')

    expect(User.find_by(email: 'pat@example.com')).to be_nil
  end

  it 'answers 422 with full error messages keyed by attribute, and nothing secret' do
    sign_up(email: '', password: 'Zq7!x', password_confirmation: 'Nope-9')

    expect(response).to have_http_status(:unprocessable_entity)
    errors = response.parsed_body.fetch('errors')
    expect(errors.fetch('email')).to include("Email can't be blank")
    expect(errors.keys).to include('password', 'password_confirmation')
    expect(User.find_by(username: 'pat_example')).to be_nil
    expect(response.body).not_to include('Zq7!x')
    expect(response.body).not_to include('Nope-9')
  end

  it 'answers 201 with the confirmation message and where to go' do
    sign_up

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to eq(
      'message' => I18n.t('devise.registrations.signed_up_but_unconfirmed', locale: :en),
      'redirect_to' => '/en/login'
    )
  end

  it 'creates an unconfirmed user who is signed in by the confirmation link' do
    ActionMailer::Base.deliveries.clear

    sign_up

    expect(response).to have_http_status(:created)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq(['pat@example.com'])
    link = mail.body.to_s[/href="([^"]*confirmation_token=[^"]*)"/, 1]
    expect(link).to be_present

    user = User.find_by!(email: 'pat@example.com')
    expect(user.confirmed_at).to be_nil

    get CGI.unescapeHTML(link)

    expect(user.reload.confirmed_at).not_to be_nil
    expect(response).to redirect_to('/en/pins')
  end
end
