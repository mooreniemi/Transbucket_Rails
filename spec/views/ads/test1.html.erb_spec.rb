require 'rails_helper'

RSpec.describe 'ads/_test1' do
  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    allow(view).to receive(:ads_allowed?).and_return(ads_allowed)
  end

  context 'on a pin submission form' do
    let(:ads_allowed) { false }

    it 'renders no AdSense markup' do
      render partial: 'ads/test1'

      expect(rendered).not_to include('adsbygoogle')
      expect(rendered).not_to include('pagead2.googlesyndication.com')
    end
  end

  context 'elsewhere in production' do
    let(:ads_allowed) { true }

    it 'continues to render the ad' do
      render partial: 'ads/test1'

      expect(rendered).to include('adsbygoogle')
    end
  end
end
