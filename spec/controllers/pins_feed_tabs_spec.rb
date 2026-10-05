require 'rails_helper'

# Recent / For You stay on screen while feed filters are applied, greyed out,
# so it's clear the filters take priority (and the toolbar doesn't jump).
describe PinsController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:procedure) { create(:procedure) }

  before { sign_in(user) }

  def tabs
    Nokogiri::HTML(response.body).at_css('.submission-feed-tabs')
  end

  def hint
    Nokogiri::HTML(response.body).at_css('.feed-tabs-paused')
  end

  context 'for someone who gets a For You feed' do
    before { user.update!(gender: create(:gender, name: 'MTF')) }

    it 'shows both tabs as links when no filter is on' do
      get :index, params: { locale: 'en' }

      expect(tabs.css('a').map { |a| a.text.strip }).to eq(['Recent', 'For You'])
      expect(tabs.css('[aria-disabled]')).to be_empty
      expect(hint).to be_nil
    end

    it 'keeps both tabs, greyed out and not tappable, while a filter is on' do
      get :index, params: { locale: 'en', procedure: [procedure.id.to_s] }

      expect(tabs).to be_present
      items = tabs.css('li')
      expect(items.map { |li| li.text.strip }).to eq(['Recent', 'For You'])
      expect(items.map { |li| li.at_css('[aria-disabled="true"]') }).to all(be_present)
      expect(tabs.css('a')).to be_empty
    end

    it 'says why and offers to clear the filters' do
      get :index, params: { locale: 'en', procedure: [procedure.id.to_s] }

      expect(hint.text).to include('Filters are on')
      clear = hint.at_css('a')
      expect(clear.text.strip).to eq('Clear filters')
      expect(clear['href']).to eq(pins_path(locale: 'en'))
    end
  end

  it "shows no tabs for someone without a For You feed, filtered or not" do
    user.update!(gender: create(:gender, name: 'GenderQueer'))

    get :index, params: { locale: 'en', procedure: [procedure.id.to_s] }

    expect(tabs).to be_nil
    expect(hint).to be_nil
  end

  it 'shows no tabs on search results' do
    user.update!(gender: create(:gender, name: 'FTM'))
    allow(PinSearchQuery).to receive(:all_xfields).and_return({ query: { match_all: {} } })
    allow(Pin).to receive(:search).and_raise(Faraday::ConnectionFailed, 'no search in this spec')

    get :index, params: { locale: 'en', query: 'anything' }

    expect(tabs).to be_nil
  end
end
