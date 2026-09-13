require 'rails_helper'

describe 'locale-prefixed URLs', type: :request do
  REQUEST_SUPPORTED_LOCALES = %w[en de es fr it ja zh-CN zh-TW pt-BR nl pl ru tr vi ar sv].freeze

  after { I18n.locale = :en }

  it 'redirects the legacy homepage to the English URL' do
    get '/', params: { query: 'phallo' }

    expect(response).to redirect_to('/en/?query=phallo')
    expect(response.status).to eq(301)
  end

  it 'redirects legacy public paths while preserving the query string' do
    get '/procedures', params: { query: 'phallo' }

    expect(response).to redirect_to('/en/procedures?query=phallo')
    expect(response.status).to eq(301)
  end

  it 'converts query-string locales to prefixed paths' do
    get '/procedures', params: { locale: 'de', query: 'phallo' }

    expect(response).to redirect_to('/de/procedures?query=phallo')
    expect(response.status).to eq(301)
  end

  it 'serves a prefixed path without redirecting' do
    get '/de/'

    expect(response).to be_success
    expect(response.body).to include('Gemeinschaftliche Fotosammlung für geschlechtsangleichende Eingriffe')
  end

  it 'does not redirect form submissions from legacy paths' do
    post '/contact', params: { message: { name: 'Test', email: 'test@example.com', subject: 'Test', body: 'Test' } }

    expect(response.status).not_to eq(301)
  end

  it 'does not redirect form submissions with a query-string locale' do
    post '/contact', params: { locale: 'de', message: { name: 'Test', email: 'test@example.com', subject: 'Test', body: 'Test' } }

    expect(response.status).not_to eq(301)
  end

  it 'keeps the locale in generated navigation URLs' do
    get '/de/'

    expect(response.body).to include('href="/de/procedures"')
    expect(response.body).to include('href="/de/surgeons"')
    expect(response.body).to include('rel="canonical" href="http://www.example.com/de"')
    expect(response.body).to include('hreflang="x-default" href="http://www.example.com/en"')
    expect(response.body).to include('hreflang="de" href="http://www.example.com/de"')
    expect(response.body).to include('"url":"http://www.example.com/de"')
  end

  it 'keeps footer language links on the current page' do
    get '/de/procedures'

    expect(response.body).to include('href="/en/procedures"')

    get '/de/newsfeed'

    expect(response.body).to include('href="/en/newsfeed"')
  end

  it 'rejects unsupported locale prefixes instead of treating them as English' do
    expect { get '/xx/' }.to raise_error(ActionController::RoutingError)
  end

  it 'uses the request locale for the document language' do
    get '/pt-BR/'

    expect(response).to be_success
    expect(response.body).to include('<html lang="pt-BR">')
  end

  it 'serves the Swedish homepage and keeps its locale in links' do
    get '/sv/'

    expect(response).to be_success
    expect(response.body).to include('<html lang="sv">')
    expect(response.body).to include('Verkliga erfarenheter av könsbekräftande ingrepp')
    expect(response.body).to include('href="/sv/procedures"')
  end

  it 'renders the login and registration forms for every locale' do
    original_caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = true

    REQUEST_SUPPORTED_LOCALES.each do |locale|
      get "/#{locale}/users/sign_in"
      expect(response).to be_success, "login form failed for #{locale}"
      expect(response.body).to include('id="new_user"'), "login form missing for #{locale}"

      get "/#{locale}/register"
      expect(response).to be_success, "registration form failed for #{locale}"
      expect(response.body).to include('id="new_user"'), "registration form missing for #{locale}"
    end
  ensure
    ActionController::Base.perform_caching = original_caching
  end

  it 'has every translation used by the signup form in every locale' do
    signup_keys = %w[username email password name gender tos]

    REQUEST_SUPPORTED_LOCALES.each do |locale|
      signup_keys.each do |key|
        expect(I18n.exists?("explanations.#{key}", locale)).to be(true), "missing explanations.#{key} for #{locale}"
      end
      %w[username password password_confirmation your_name gender].each do |key|
        expect(I18n.exists?("public.auth.#{key}", locale)).to be(true), "missing public.auth.#{key} for #{locale}"
      end
      expect(I18n.exists?('account_menu.register', locale)).to be(true), "missing registration label for #{locale}"
      expect(I18n.exists?('account_menu.login', locale)).to be(true), "missing login label for #{locale}"
    end
  end

  it 'has visible labels for every stored gender in every locale' do
    %w[FTM MTF GenderQueer None Cisgender].each do |gender|
      REQUEST_SUPPORTED_LOCALES.each do |locale|
        expect(I18n.exists?("gender_labels.#{gender}", locale)).to be(true), "missing gender label #{gender} for #{locale}"
      end
    end
  end
end
