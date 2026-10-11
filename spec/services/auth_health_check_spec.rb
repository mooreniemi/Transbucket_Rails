require 'rails_helper'

describe AuthHealthCheck do
  let(:now) { Time.current }

  def signed_in_event(user, occurred_at)
    ContentEvent.create!(user: user, content_type: 'Procedure', content_id: 1,
                         event_type: 'view', source: 'client', occurred_at: occurred_at)
  end

  it 'is healthy when every kind of activity is recent' do
    user = create(:user, created_at: 2.hours.ago, current_sign_in_at: 30.minutes.ago)
    signed_in_event(user, 10.minutes.ago)

    check = described_class.new(now: now)
    expect(check).to be_healthy
    expect(check.failing).to be_empty
  end

  it 'names each check whose latest activity is too old' do
    user = create(:user, created_at: 7.hours.ago, current_sign_in_at: 4.hours.ago)
    signed_in_event(user, 2.hours.ago)

    expect(described_class.new(now: now).failing).to contain_exactly('signed_in_activity', 'logins', 'signups')
  end

  it 'fails a check with no activity at all' do
    create(:user, created_at: 1.hour.ago, current_sign_in_at: nil)

    expect(described_class.new(now: now).failing).to contain_exactly('signed_in_activity', 'logins')
  end

  it 'uses the newest sign-up and signed-in event, not the oldest' do
    old_user = create(:user, created_at: 2.days.ago, current_sign_in_at: 1.hour.ago)
    create(:user, created_at: 1.hour.ago)
    signed_in_event(old_user, 2.days.ago)
    signed_in_event(old_user, 5.minutes.ago)

    expect(described_class.new(now: now)).to be_healthy
  end

  it 'leaves the connection writable afterwards' do
    described_class.new(now: now).failing

    expect { create(:user) }.not_to raise_error
  end

  it 'runs its queries in a read-only transaction' do
    allow(User).to receive(:maximum) { User.connection.execute("UPDATE users SET username = username") }

    expect { described_class.new(now: now).failing }.to raise_error(ActiveRecord::StatementInvalid, /read-only transaction/)
  end
end
