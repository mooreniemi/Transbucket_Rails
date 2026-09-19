require 'rails_helper'

describe ContentEvent do
  it 'records an anonymous procedure view using only pseudonymous hashes' do
    event = ContentEvent.new(
      visitor_hash: 'a' * 64,
      network_hash: 'b' * 64,
      content_type: 'Procedure',
      content_id: 42,
      event_type: 'view',
      occurred_at: Time.current
    )

    expect(event).to be_valid
  end

  it 'records a signed-in surgeon view without an anonymous identifier' do
    event = ContentEvent.new(
      user: create(:user),
      content_type: 'Surgeon',
      content_id: 42,
      event_type: 'view',
      occurred_at: Time.current
    )

    expect(event).to be_valid
  end

  it 'requires an actor signal and a supported content event' do
    event = ContentEvent.new(
      content_type: 'User',
      content_id: 42,
      event_type: 'save',
      occurred_at: Time.current
    )

    expect(event).not_to be_valid
    expect(event.errors[:content_type]).not_to be_empty
    expect(event.errors[:event_type]).not_to be_empty
    expect(event.errors[:base]).not_to be_empty
  end
end
