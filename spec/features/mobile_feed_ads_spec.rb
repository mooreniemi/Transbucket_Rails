require 'rails_helper'

# Ads in the phone feed. Infinite scroll adds each page's cards as HTML, and
# HTML added that way does not run its scripts, so feed_scroll.js has to start
# the ad slots itself: once each, loading Google's script if no page needed it
# yet, and re-flowing the feed when an ad changes size. Google is replaced by a
# small stand-in script that answers the way Google does (marks the slot, then
# sets its status and size), so nothing here calls Google.
RSpec.describe 'ads in the phone feed', js: true, fake_images: true do
  let!(:user) { create(:user, :with_confirmation) }

  # Stands in for adsbygoogle.js: drains pushes made before it loaded, and for
  # each push marks the next unstarted slot, then reports `status`.
  def stand_in_script(status)
    js = <<-JAVASCRIPT
      (function() {
        // Every slot on a page carries its own copy of the script tag, as on
        // the real site; like Google's script, load only once.
        if (window.adsbygoogle && window.adsbygoogle.loaded) { return; }
        var queued = window.adsbygoogle || [];
        var api = {
          loaded: true,
          pushes: 0,
          push: function() {
            api.pushes += 1;
            var slot = document.querySelector('ins.adsbygoogle:not([data-adsbygoogle-status])');
            if (!slot) { return; }
            slot.setAttribute('data-adsbygoogle-status', 'done');
            setTimeout(function() {
              slot.setAttribute('data-ad-status', #{status.to_json});
              slot.style.height = #{status == 'filled' ? "'250px'" : "'0px'"};
            }, 50);
          }
        };
        window.adsbygoogle = api;
        for (var i = 0; i < queued.length; i += 1) { api.push(); }
      })();
    JAVASCRIPT
    "data:text/javascript;charset=utf-8,#{ERB::Util.url_encode(js)}"
  end

  def use_ads(status: 'filled')
    @saved_ad_settings = %i[show_ads feed_ad_odds ad_script_src].map { |key| [key, Rails.configuration.x.public_send(key)] }.to_h
    Rails.configuration.x.show_ads = true
    Rails.configuration.x.feed_ad_odds = 1 # an ad before every card
    Rails.configuration.x.ad_script_src = stand_in_script(status)
  end

  before do
    Rails.cache.clear
    allow(Pin).to receive(:per_page).and_return(2)
    create_list(:pin, 5, user: user)
    login_as(user, scope: :user)
    page.current_window.resize_to(390, 800)
  end

  # Put the settings back for the specs that follow.
  after do
    @saved_ad_settings&.each { |key, value| Rails.configuration.x.public_send("#{key}=", value) }
  end

  def scroll_through_the_feed
    8.times do
      break if page.has_css?('#pins .item[data-pin-id]', count: 5, wait: 1)
      page.execute_script('window.scrollTo(0, document.body.scrollHeight)')
    end
    expect(page).to have_css('#pins .item[data-pin-id]', count: 5)
  end

  def eventually(seconds = 8)
    Timeout.timeout(seconds) do
      sleep 0.05 until yield
    end
    true
  rescue Timeout::Error
    false
  end

  def ad_impressions
    ContentEvent.where(content_type: 'Page', content_id: TrackedTarget.id_for('ad_slot'), event_type: 'impression')
  end

  # Cards stacked without any covering another (Masonry places them from
  # measured heights, so an ad growing after the fact must trigger a re-layout).
  def feed_cards_overlap?
    !page.evaluate_script(<<-JAVASCRIPT)
      (function() {
        var boxes = Array.prototype.filter.call(document.querySelectorAll('#pins > .item'), function(item) {
          return item.offsetHeight > 0;
        }).map(function(item) {
          var rect = item.getBoundingClientRect();
          return [rect.top + window.scrollY, rect.bottom + window.scrollY];
        }).sort(function(a, b) { return a[0] - b[0]; });
        for (var i = 1; i < boxes.length; i += 1) {
          if (boxes[i][0] < boxes[i - 1][1] - 1) { return false; }
        }
        return true;
      })()
    JAVASCRIPT
  end

  it 'brings in the ad slots of every page, starts each exactly once, and records them' do
    use_ads
    visit '/en/pins'

    scroll_through_the_feed

    expect(page).to have_css('.pin-ad-slot', count: 5)
    expect(page).to have_css("ins.adsbygoogle[data-adsbygoogle-status='done']", count: 5)
    expect(page.evaluate_script('window.adsbygoogle.pushes')).to eq(5)
    expect(eventually { ad_impressions.count == 5 }).to be(true)
    expect(ad_impressions.map { |event| event.event_context.values_at('surface', 'status') }.uniq).to eq([%w[pins_index filled]])
  end

  it 'lays the feed out again when ads arrive, so none covers a card' do
    use_ads
    visit '/en/pins'
    scroll_through_the_feed

    expect(page).to have_css("ins.adsbygoogle[data-ad-status='filled']", count: 5)
    expect(eventually { !feed_cards_overlap? }).to be(true)
  end

  it "loads Google's script from a later page when the first page had no ad" do
    use_ads
    Rails.configuration.x.show_ads = false
    visit '/en/pins'
    expect(page).to have_css('#pins .item[data-pin-id]', count: 2)
    expect(page).not_to have_css('.pin-ad-slot')
    expect(page.evaluate_script('typeof window.adsbygoogle')).to eq('undefined')

    Rails.configuration.x.show_ads = true
    scroll_through_the_feed

    expect(page).to have_css('.pin-ad-slot', count: 3)
    expect(page).to have_css("ins.adsbygoogle[data-adsbygoogle-status='done']", count: 3)
    expect(page.evaluate_script('window.adsbygoogle.pushes')).to eq(3)
    expect(page.evaluate_script("document.querySelectorAll('script[src^=\"data:text/javascript\"]').length")).to eq(1)
  end

  it 'gives back the space of slots Google does not fill, leaving no gap' do
    use_ads(status: 'unfilled')
    visit '/en/pins'

    scroll_through_the_feed

    expect(page).to have_css('.pin-ad-slot.ad-collapsed', count: 5, visible: :all)
    expect(page).not_to have_css('.pin-ad-slot', visible: true)
    expect(eventually { ad_impressions.count == 5 }).to be(true)
    expect(ad_impressions.map { |event| event.event_context['status'] }.uniq).to eq(['unfilled'])
    expect(feed_cards_overlap?).to be(false)
  end
end
