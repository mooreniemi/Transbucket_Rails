require 'rails_helper'

describe ContentEventRecorder do
  let(:request) { double(remote_ip: '203.0.113.8') }

  it 'records an anonymous procedure view with one-way, non-raw identifiers' do
    procedure = create(:procedure)

    expect(described_class.record(
      request: request,
      current_user: nil,
      locale: :en,
      content_type: 'Procedure',
      content_id: procedure.id,
      event_type: 'view',
      visitor_id: 'browser-only-id'
    )).to be(true)

    event = ContentEvent.last
    expect(event).to have_attributes(content_type: 'Procedure', content_id: procedure.id, event_type: 'view', source: 'client', locale: 'en')
    expect(event.visitor_hash).to match(/\A[0-9a-f]{64}\z/)
    expect(event.network_hash).to match(/\A[0-9a-f]{64}\z/)
    expect(event.visitor_hash).not_to include('browser-only-id')
    expect(event.network_hash).not_to include('203.0.113.8')
  end

  it 'records a signed-in surgeon view without anonymous identifiers' do
    surgeon = create(:surgeon)
    user = create(:user)

    expect(described_class.record(
      request: request,
      current_user: user,
      locale: :fr,
      content_type: 'Surgeon',
      content_id: surgeon.id,
      event_type: 'view',
      visitor_id: nil
    )).to be(true)

    expect(ContentEvent.last).to have_attributes(user: user, visitor_hash: nil, network_hash: nil, locale: 'fr')
  end

  it 'deduplicates a visitor viewing the same content within thirty minutes' do
    procedure = create(:procedure)
    attributes = {
      request: request, current_user: nil, locale: :en, content_type: 'Procedure',
      content_id: procedure.id, event_type: 'view', visitor_id: 'same-browser'
    }

    expect(described_class.record(attributes)).to be(true)
    expect(described_class.record(attributes)).to be(false)
    expect(ContentEvent.count).to eq(1)
  end

  it 'records a Pin-card impression and open only for a real Pin' do
    pin = create(:pin)
    attributes = {
      request: request, current_user: nil, locale: :en, content_type: 'Pin',
      content_id: pin.id, visitor_id: 'browser'
    }

    expect(described_class.record(attributes.merge(event_type: 'impression'))).to be(true)
    expect(described_class.record(attributes.merge(event_type: 'open'))).to be(true)
    expect(ContentEvent.pluck(:event_type)).to match_array(%w[impression open])
  end

  it 'refuses unknown records and events without writing anything' do
    expect(described_class.record(
      request: request, current_user: nil, locale: :en, content_type: 'Pin',
      content_id: 999, event_type: 'gallery_open', visitor_id: 'browser'
    )).to be(false)

    expect(ContentEvent.count).to eq(0)
  end

  it 'refuses an anonymous event without its browser-only visitor identifier' do
    procedure = create(:procedure)

    expect(described_class.record(
      request: request, current_user: nil, locale: :en, content_type: 'Procedure',
      content_id: procedure.id, event_type: 'view', visitor_id: nil
    )).to be(false)

    expect(ContentEvent.count).to eq(0)
  end

  it 'swallows a database failure so telemetry cannot escape to the request' do
    procedure = create(:procedure)
    allow(ContentEvent).to receive(:transaction).and_raise(ActiveRecord::StatementInvalid, 'database unavailable')

    expect(described_class.record(
      request: request, current_user: nil, locale: :en, content_type: 'Procedure',
      content_id: procedure.id, event_type: 'view', visitor_id: 'browser'
    )).to be(false)
  end
end
