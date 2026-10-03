# Answers "are people still signing up, logging in and browsing signed in?"
# for the scheduled `rake health:check`, which emails an alert naming the
# failing checks. Zero activity on any of them usually means auth is broken.
#
# Each check reads one newest row, so it stays cheap as tables grow, and runs
# in a read-only transaction that is always rolled back.
class AuthHealthCheck
  # Thresholds sit well above the quietest hour on production (about 0.5
  # sign-ups, 2 logins and 50 signed-in content events per hour), so a quiet
  # night should not page anyone.
  MAX_AGES = {
    'signed_in_activity' => 1.hour,
    'logins' => 3.hours,
    'signups' => 6.hours
  }.freeze

  def initialize(now: Time.current)
    @now = now
  end

  def failing
    @failing ||= latest_times.select { |name, time| time.nil? || time < @now - MAX_AGES.fetch(name) }.keys
  end

  def healthy?
    failing.empty?
  end

  private

  def latest_times
    times = nil
    ActiveRecord::Base.transaction(requires_new: true) do
      ActiveRecord::Base.connection.execute('SET LOCAL transaction_read_only = on')
      times = {
        'signed_in_activity' => ContentEvent.where.not(user_id: nil).order(id: :desc).limit(1).pluck(:occurred_at).first,
        'logins' => User.maximum(:current_sign_in_at),
        'signups' => User.order(id: :desc).limit(1).pluck(:created_at).first
      }
      raise ActiveRecord::Rollback
    end
    times
  end
end
