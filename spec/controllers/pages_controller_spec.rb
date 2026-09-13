require 'rails_helper'

describe PagesController, :type => :controller do
  render_views

  after { I18n.locale = I18n.default_locale }

  it 'renders pages when fragment caching is enabled' do
    allow(controller).to receive(:perform_caching).and_return(true)
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    get 'home', params: { locale: 'en' }

    expect(response).to be_success
  ensure
    Rails.cache = original_cache
  end

  describe 'locale selection' do
    it 'uses an explicitly selected supported locale' do
      get 'home', params: { locale: 'de' }

      expect(response).to be_success
      expect(I18n.locale.to_s).to eq('de')
      expect(response.body).to include('Gemeinschaftliche Fotosammlung für geschlechtsangleichende Eingriffe')
      expect(response.body).to include('hreflang="pt-BR"')
    end

    it 'falls back to English for unsupported locales' do
      get 'home', params: { locale: 'xx' }

      expect(response).to be_success
      expect(I18n.locale.to_s).to eq('en')
      expect(response.body).to include('Community Photo-Sharing for Transition and Gender-Affirming Procedures')
    end
  end

  describe 'GET newsfeed' do
    it 'renders a static archive without fetching tumblr' do
      expect(URI).not_to receive(:open)

      get 'newsfeed', params: { locale: 'en' }

      expect(response).to be_success
      expect(assigns(:newsfeed_entries).length).to eq(5)
      expect(assigns(:newsfeed_entries).map { |entry| entry[:body] }).to include(I18n.t('newsfeed.entries.directory_improvements'))
      expect(response.body).to include('We cleaned up a set of procedure names')
      expect(response.body).to include('Procedure search now matches prefixes')
      expect(response.body).to include('The Discord community invite now points to a permanent link.')
      expect(response.body).to include('Transbucket now supports German, Spanish, French, Italian')
    end

    it 'localizes the release notes' do
      get 'newsfeed', params: { locale: 'de' }

      expect(response).to be_success
      expect(response.body).to include('Die Verfahrenssuche findet jetzt Präfixe')
      expect(response.body).not_to include('Procedure search now matches prefixes')
    end
  end

  describe 'GET about' do
    it 'does not label the informational page as legal content' do
      get 'about', params: { locale: 'de' }

      expect(response).to be_success
      expect(response.body).not_to include(I18n.t('legal.translation_notice', locale: :de))
    end
  end
end
