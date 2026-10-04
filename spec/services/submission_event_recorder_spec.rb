require 'rails_helper'

describe SubmissionEventRecorder do
  let(:user) { create(:user) }
  let(:pin) { create(:pin, user: user) }

  it 'records a server-side submission_created event for the pin and its author' do
    expect(described_class.record(pin: pin, user: user, event_type: 'submission_created', locale: :de)).to eq(true)

    event = ContentEvent.last
    expect(event).to have_attributes(
      content_type: 'Pin',
      content_id: pin.id,
      event_type: 'submission_created',
      source: 'server',
      user_id: user.id,
      locale: 'de',
      visitor_hash: nil,
      network_hash: nil
    )
    expect(event.occurred_at).to be_within(1.minute).of(Time.current)
  end

  it 'records submission_updated for the user who made the edit' do
    editor = create(:user, admin: true)

    described_class.record(pin: pin, user: editor, event_type: 'submission_updated', locale: :en)

    expect(ContentEvent.last).to have_attributes(event_type: 'submission_updated', user_id: editor.id, content_id: pin.id)
  end

  it 'records every edit rather than collapsing repeats' do
    2.times { described_class.record(pin: pin, user: user, event_type: 'submission_updated', locale: :en) }

    expect(ContentEvent.where(event_type: 'submission_updated', content_id: pin.id).count).to eq(2)
  end

  it 'refuses event types that are not submissions' do
    expect(described_class.record(pin: pin, user: user, event_type: 'view', locale: :en)).to eq(false)
    expect(ContentEvent.count).to eq(0)
  end

  it 'refuses a pin that has not been saved' do
    expect(described_class.record(pin: build(:pin), user: user, event_type: 'submission_created', locale: :en)).to eq(false)
    expect(ContentEvent.count).to eq(0)
  end

  it 'refuses an event without a user' do
    expect(described_class.record(pin: pin, user: nil, event_type: 'submission_created', locale: :en)).to eq(false)
    expect(ContentEvent.count).to eq(0)
  end

  it 'never raises when the events table fails, so a submission cannot break on tracking' do
    pin
    allow(ContentEvent).to receive(:create!).and_raise(ActiveRecord::StatementInvalid, 'canceling statement due to statement timeout')

    expect { described_class.record(pin: pin, user: user, event_type: 'submission_created', locale: :en) }.not_to raise_error
    expect(described_class.record(pin: pin, user: user, event_type: 'submission_created', locale: :en)).to eq(false)
  end
end
