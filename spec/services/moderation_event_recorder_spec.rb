require 'rails_helper'

describe ModerationEventRecorder do
  it 'records the actor, target, action, and timestamp' do
    user = create(:user)
    pin = create(:pin)

    described_class.record(action: :flag, user: user, content: pin)

    expect(ModerationEvent.last).to have_attributes(
      user: user,
      action: 'flag',
      content_type: 'Pin',
      content_id: pin.id
    )
    expect(ModerationEvent.last.occurred_at).to be_present
  end

  it 'fails open when history persistence fails' do
    allow(ModerationEvent).to receive(:create!).and_raise(ActiveRecord::StatementInvalid, 'database unavailable')

    expect(described_class.record(action: :flag, user: create(:user), content: create(:pin))).to be_nil
  end
end
