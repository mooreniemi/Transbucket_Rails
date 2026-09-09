require 'rails_helper'

describe 'locale-prefixed URLs', type: :request do
  SUPPORTED_LOCALES = %w[en de es fr it ja zh-CN zh-TW pt-BR nl pl ru tr vi ar].freeze

  after { I18n.locale = :en }

  it 'redirects the legacy homepage to the English URL' do
    get '/', query: 'phallo'

    expect(response).to redirect_to('/en/?query=phallo')
    expect(response.status).to eq(301)
  end

  it 'redirects legacy public paths while preserving the query string' do
    get '/procedures', query: 'phallo'

    expect(response).to redirect_to('/en/procedures?query=phallo')
    expect(response.status).to eq(301)
  end

  it 'converts query-string locales to prefixed paths' do
    get '/procedures', locale: 'de', query: 'phallo'

    expect(response).to redirect_to('/de/procedures?query=phallo')
    expect(response.status).to eq(301)
  end

  it 'serves a prefixed path without redirecting' do
    get '/de/'

    expect(response).to be_success
    expect(response.body).to include('Gemeinschaftliche Fotosammlung für geschlechtsangleichende Eingriffe')
  end

  it 'does not redirect form submissions from legacy paths' do
    post '/contact', message: { name: 'Test', email: 'test@example.com', subject: 'Test', body: 'Test' }

    expect(response.status).not_to eq(301)
  end

  it 'does not redirect form submissions with a query-string locale' do
    post '/contact', locale: 'de', message: { name: 'Test', email: 'test@example.com', subject: 'Test', body: 'Test' }

    expect(response.status).not_to eq(301)
  end

  it 'keeps the locale in generated navigation URLs' do
    get '/de/'

    expect(response.body).to include('href="/de/procedures"')
    expect(response.body).to include('href="/de/surgeons"')
    expect(response.body).to include('rel="canonical" href="http://www.example.com/de"')
    expect(response.body).to include('hreflang="x-default" href="/en"')
    expect(response.body).to include('"url":"http://www.example.com/de"')
  end

  it 'rejects unsupported locale prefixes instead of treating them as English' do
    expect { get '/xx/' }.to raise_error(ActionController::RoutingError)
  end

  it 'uses the request locale for the document language' do
    get '/pt-BR/'

    expect(response).to be_success
    expect(response.body).to include('<html lang="pt-BR">')
  end

  it 'has every translation used by the signup form in every locale' do
    signup_keys = %w[username email password name gender tos]

    SUPPORTED_LOCALES.each do |locale|
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
end
