require 'rails_helper'

describe 'locale-prefixed URLs', type: :request do
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
end
