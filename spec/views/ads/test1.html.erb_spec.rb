require 'rails_helper'

RSpec.describe 'ads/_test1' do
  before do
    # Ads show in production only; switch that setting on for these examples.
    @show_ads = Rails.configuration.x.show_ads
    Rails.configuration.x.show_ads = true
    allow(view).to receive(:ads_allowed?).and_return(ads_allowed)
  end

  after { Rails.configuration.x.show_ads = @show_ads }

  context 'on a pin submission form' do
    let(:ads_allowed) { false }

    it 'renders no AdSense markup' do
      render partial: 'ads/test1'

      expect(rendered).not_to include('adsbygoogle')
      expect(rendered).not_to include('pagead2.googlesyndication.com')
    end
  end

  context 'outside production' do
    let(:ads_allowed) { true }

    it 'renders no AdSense markup' do
      Rails.configuration.x.show_ads = false

      render partial: 'ads/test1', locals: { surface: 'procedures_index' }

      expect(rendered).not_to include('adsbygoogle')
    end
  end

  context 'elsewhere in production' do
    let(:ads_allowed) { true }

    it 'wraps the slot with what ad_tracking.js needs to report on it' do
      render partial: 'ads/test1', locals: { surface: 'procedures_index' }

      wrapper = Nokogiri::HTML.fragment(rendered).at_css('[data-ad-slot-tracking]')
      expect(wrapper['data-ad-surface']).to eq('procedures_index')
      expect(wrapper['data-content-id']).to eq(TrackedTarget.id_for('ad_slot').to_s)
      expect(wrapper['data-content-event-url']).to eq(view.content_events_path)
      expect(wrapper.at_css('ins.adsbygoogle')).to be_present
    end

    it 'continues to render the ad' do
      render partial: 'ads/test1'

      expect(rendered).to include('adsbygoogle')
    end
  end
end
