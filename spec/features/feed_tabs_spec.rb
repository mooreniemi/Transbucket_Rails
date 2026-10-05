require 'rails_helper'

# Turning a filter on must not move the feed toolbar: Recent / For You stay
# where they were (greyed out) instead of disappearing.
RSpec.describe 'feed tabs while filtering, on a phone', js: true do
  let!(:user) { create(:user, :with_confirmation, gender: create(:gender, name: 'FTM')) }
  let!(:procedure) { create(:procedure) }

  before do
    login_as(user, scope: :user)
    page.current_window.resize_to(390, 800)
  end

  after do
    page.current_window.resize_to(1400, 1000)
    Warden.test_reset!
  end

  def tabs_box
    page.evaluate_script(<<~JS)
      (function() {
        var tabs = document.querySelector('.submission-feed-tabs');
        if (!tabs) { return null; }
        var r = tabs.getBoundingClientRect();
        return { top: Math.round(r.top), height: Math.round(r.height) };
      })()
    JS
  end

  it 'keeps the tabs in the same place when a filter is applied' do
    visit '/en/pins'
    before = tabs_box

    visit "/en/pins?procedure[]=#{procedure.id}"
    after = tabs_box

    expect(before).to be_present
    expect(after).to eq(before)
  end
end
