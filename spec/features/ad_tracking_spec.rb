require 'rails_helper'

# ad_tracking.js: how our ad slots fare, recorded as our own events. Ads only
# render in production, so these specs put slots on the page built the same way
# as ads/_slot (checked in spec/views/ads), and play out each way a slot can end.
RSpec.describe 'ad slot tracking', js: true do
  FAST = { pollMs: 40, giveUpMs: 500, viewMs: 200 }.freeze

  let(:ad_slot_id) { TrackedTarget.id_for('ad_slot') }

  def ad_events
    ContentEvent.where(content_type: 'Page', content_id: ad_slot_id).order(:id)
  end

  def wait_for_ad_events(count)
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.05 until ad_events.count >= count
    end
  rescue Timeout::Error
    # Fall through: the expectation below reports what was recorded.
  end

  # A slot like ads/_slot renders, plus whatever the case needs on the <ins>.
  def add_slot(surface: 'procedures_index', status: nil, hide: false, set_status_later: nil)
    page.execute_script(<<-JAVASCRIPT, surface, content_events_path(locale: 'en'), ad_slot_id, status, hide, set_status_later)
      var args = arguments;
      var wrapper = document.createElement('div');
      wrapper.className = 'ad-slot';
      wrapper.setAttribute('data-ad-slot-tracking', '');
      wrapper.setAttribute('data-ad-surface', args[0]);
      wrapper.setAttribute('data-content-event-url', args[1]);
      wrapper.setAttribute('data-content-id', String(args[2]));
      var ins = document.createElement('ins');
      ins.className = 'adsbygoogle';
      ins.style.display = 'block';
      ins.style.height = '120px';
      if (args[3]) { ins.setAttribute('data-ad-status', args[3]); }
      if (args[4]) { ins.style.setProperty('display', 'none', 'important'); }
      wrapper.appendChild(ins);
      document.body.insertBefore(wrapper, document.body.firstChild);
      if (args[5]) { setTimeout(function() { ins.setAttribute('data-ad-status', args[5]); }, 150); }
      window.trackAdSlots(document, #{FAST.to_json});
    JAVASCRIPT
  end

  before { visit '/en/procedures' }

  it 'sends nothing on a page without ads' do
    sleep 1

    expect(ad_events.count).to eq(0)
  end

  it 'records a filled ad as an impression and, once it has been on screen, a view' do
    add_slot(status: 'filled')

    wait_for_ad_events(2)

    expect(ad_events.pluck(:event_type, :event_context)).to eq([
      ['impression', { 'surface' => 'procedures_index', 'status' => 'filled' }],
      ['view', { 'surface' => 'procedures_index', 'status' => 'filled' }]
    ])
  end

  it 'does not count a filled ad as viewed when it is not on screen' do
    add_slot(status: 'filled')
    page.execute_script("document.querySelector('.ad-slot').style.position = 'absolute'; document.querySelector('.ad-slot').style.top = '-5000px';")

    wait_for_ad_events(1)
    sleep 0.6

    expect(ad_events.pluck(:event_type)).to eq(['impression'])
  end

  it 'records Google declining to fill the slot, with no view' do
    add_slot(status: 'unfill-optimized', surface: 'surgeons_index')

    wait_for_ad_events(1)
    sleep 0.5

    expect(ad_events.pluck(:event_type, :event_context)).to eq([
      ['impression', { 'surface' => 'surgeons_index', 'status' => 'unfill-optimized' }]
    ])
  end

  it 'waits for Google to answer, then records what it said' do
    add_slot(status: nil, set_status_later: 'unfilled')

    wait_for_ad_events(1)

    expect(ad_events.last.event_context['status']).to eq('unfilled')
  end

  it 'records a slot an ad blocker has hidden' do
    add_slot(hide: true, surface: 'pins_index')

    wait_for_ad_events(1)

    expect(ad_events.pluck(:event_type, :event_context)).to eq([
      ['impression', { 'surface' => 'pins_index', 'status' => 'hidden' }]
    ])
  end

  it "records Google's script never loading" do
    page.execute_script('delete window.adsbygoogle;')
    add_slot

    wait_for_ad_events(1)

    expect(ad_events.last.event_context['status']).to eq('script_blocked')
  end

  it 'records a script that loaded but never answered' do
    page.execute_script('window.adsbygoogle = { loaded: true, push: function() {} };')
    add_slot

    wait_for_ad_events(1)

    expect(ad_events.last.event_context['status']).to eq('no_response')
  end

  it 'reports each slot once however many times the page is scanned' do
    add_slot(status: 'unfilled')
    page.execute_script("window.trackAdSlots(document, #{FAST.to_json}); window.trackAdSlots(document, #{FAST.to_json});")

    wait_for_ad_events(1)
    sleep 0.5

    expect(ad_events.count).to eq(1)
  end

  it 'is recorded for signed-in members too, against their account' do
    user = create(:user, :with_confirmation)
    login_as(user, scope: :user)
    visit '/en/procedures'
    add_slot(status: 'filled')

    wait_for_ad_events(1)

    expect(ad_events.first.user_id).to eq(user.id)
    Warden.test_reset!
  end
end
