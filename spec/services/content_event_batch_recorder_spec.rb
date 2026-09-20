require 'rails_helper'

describe ContentEventBatchRecorder do
  let(:request) { double(remote_ip: '203.0.113.8') }

  it 'records one impression per real Pin in a single validated batch' do
    first_pin, second_pin = create_list(:pin, 2)

    count = described_class.record_impressions(
      request: request, current_user: nil, locale: :en, visitor_id: 'browser', client_context: {},
      events: [
        { content_type: 'Pin', content_id: first_pin.id, event_type: 'impression', event_context: { surface: 'pins_index', rank: '1' } },
        { content_type: 'Pin', content_id: second_pin.id, event_type: 'impression', event_context: { surface: 'pins_index', rank: '2' } },
        { content_type: 'Procedure', content_id: 999, event_type: 'impression', event_context: {} }
      ]
    )

    expect(count).to eq(2)
    expect(ContentEvent.where(event_type: 'impression').pluck(:content_id)).to match_array([first_pin.id, second_pin.id])
    expect(ContentEvent.find_by(content_id: second_pin.id).event_context).to include('rank' => '2')
  end

  it 'deduplicates repeated Pins within one batch' do
    pin = create(:pin)

    count = described_class.record_impressions(
      request: request, current_user: nil, locale: :en, visitor_id: 'browser', client_context: {},
      events: [
        { content_type: 'Pin', content_id: pin.id, event_type: 'impression', event_context: { rank: '1' } },
        { content_type: 'Pin', content_id: pin.id, event_type: 'impression', event_context: { rank: '1' } }
      ]
    )

    expect(count).to eq(1)
    expect(ContentEvent.where(content_type: 'Pin', content_id: pin.id, event_type: 'impression').count).to eq(1)
  end

  it 'does not record the same anonymous Pin impression twice within the deduplication window' do
    pin = create(:pin)
    attributes = {
      request: request, current_user: nil, locale: :en, visitor_id: 'same-browser', client_context: {},
      events: [{ content_type: 'Pin', content_id: pin.id, event_type: 'impression', event_context: {} }]
    }

    expect(described_class.record_impressions(attributes)).to eq(1)
    expect(described_class.record_impressions(attributes)).to eq(1)
    expect(ContentEvent.where(content_type: 'Pin', content_id: pin.id, event_type: 'impression').count).to eq(1)
  end

  it 'associates a signed-in batch with the user and preserves client context' do
    pin = create(:pin)
    user = create(:user)

    described_class.record_impressions(
      request: request, current_user: user, locale: :fr, visitor_id: nil,
      client_context: { 'device_class' => 'mobile', 'browser_family' => 'Firefox' },
      events: [{ content_type: 'Pin', content_id: pin.id, event_type: 'impression', event_context: { rank: '3' } }]
    )

    event = ContentEvent.last
    expect(event).to have_attributes(user: user, visitor_hash: nil, network_hash: nil, locale: 'fr')
    expect(event.client_context).to include('device_class' => 'mobile', 'browser_family' => 'Firefox')
    expect(event.event_context).to eq('rank' => '3')
  end

  it 'fails open when batch persistence raises' do
    pin = create(:pin)
    allow(ContentEvent).to receive(:transaction).and_raise(ActiveRecord::StatementInvalid, 'database unavailable')

    expect(described_class.record_impressions(
      request: request, current_user: nil, locale: :en, visitor_id: 'browser', client_context: {},
      events: [{ content_type: 'Pin', content_id: pin.id, event_type: 'impression', event_context: {} }]
    )).to eq(0)
  end
end
