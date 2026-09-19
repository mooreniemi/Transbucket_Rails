require 'rails_helper'

describe PagesController, :type => :controller do
  render_views

  after { I18n.locale = I18n.default_locale }

  describe 'locale selection' do
    it 'uses an explicitly selected supported locale' do
      get 'home', locale: 'de'

      expect(response).to be_success
      expect(I18n.locale.to_s).to eq('de')
      expect(response.body).to include('Gemeinschaftliche Fotosammlung für geschlechtsangleichende Eingriffe')
      expect(response.body).to include('hreflang="pt-BR"')
    end

    it 'falls back to English for unsupported locales' do
      get 'home', locale: 'xx'

      expect(response).to be_success
      expect(I18n.locale.to_s).to eq('en')
      expect(response.body).to include('Community Photo-Sharing for Transition and Gender-Affirming Procedures')
    end
  end

  describe 'GET newsfeed' do
    it 'renders a static archive without fetching tumblr' do
      expect(URI).not_to receive(:open)

      get 'newsfeed'

      expect(response).to be_success
      expect(assigns(:newsfeed_entries).length).to eq(6)
      expect(assigns(:newsfeed_entries).first[:images].length).to eq(2)
      expect(assigns(:newsfeed_entries).all? { |entry| entry[:links].present? }).to eq(true)
      expect(assigns(:newsfeed_entries).map { |entry| entry[:body] }).to include(I18n.t('newsfeed.entries.directory_improvements'))
      expect(response.body).to include('We cleaned up a set of procedure names')
      expect(response.body).to include('Procedure search now matches prefixes')
      expect(response.body).to include('The Discord community invite now points to a permanent link.')
      expect(response.body).to include('Transbucket now supports German, Spanish, French, Italian')
      expect(response.body).to include('href="/en/procedures/compare"')
      expect(response.body).to include('href="/en/surgeons/compare"')
      expect(response.body).not_to include('(Compare procedures / compare surgeons)')
    end

    it 'localizes the release notes' do
      get 'newsfeed', locale: 'de'

      expect(response).to be_success
      expect(response.body).to include('Die Verfahrenssuche findet jetzt Präfixe')
      expect(response.body).not_to include('Procedure search now matches prefixes')
    end
  end

  describe 'GET compare' do
    it 'requires authentication' do
      get 'compare', locale: 'en'

      expect(response).to redirect_to(new_user_session_path(locale: 'en'))
    end

    it 'renders the selected comparison type and preselects the first record' do
      user = create(:user)
      surgeon = create(:surgeon, first_name: 'First', last_name: 'Surgeon')
      sign_in user

      get 'compare', locale: 'en', type: 'surgeons', first_id: surgeon.to_param

      expect(response).to be_success
      expect(assigns(:comparison_type)).to eq('surgeons')
      expect(response.body).to include('<option selected="selected" value="' + surgeon.to_param + '">')
      expect(response.body).to include('action="/en/surgeons/compare"')
    end
  end

  describe 'GET about' do
    it 'does not label the informational page as legal content' do
      get 'about', locale: 'de'

      expect(response).to be_success
      expect(response.body).not_to include(I18n.t('legal.translation_notice', locale: :de))
    end
  end
end
