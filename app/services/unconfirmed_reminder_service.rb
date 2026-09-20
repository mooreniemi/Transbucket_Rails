# Emails a reminder to unconfirmed users who haven't already been reminded,
# via lib/tasks/unconfirmed_reminders.rake. Runs synchronously (not via
# handle_asynchronously/delayed_job) because production currently runs no
# worker dyno -- anything enqueued there would just sit unprocessed.
class UnconfirmedReminderService
  MAX_LIMIT = 5000

  def initialize(limit: 100, since: nil, until_time: nil, sleep_between: 0.1)
    @limit = [limit.to_i, MAX_LIMIT].min
    @since = since
    @until_time = until_time
    @sleep_between = sleep_between
  end

  def scope
    users = User.where(confirmed_at: nil, confirmation_reminder_sent_at: nil)
    users = users.where('created_at >= ?', @since) if @since
    users = users.where('created_at <= ?', @until_time) if @until_time
    users.order(created_at: :desc).limit(@limit)
  end

  def call
    reminded = 0
    scope.to_a.each do |user|
      remind!(user)
      reminded += 1
      sleep @sleep_between if @sleep_between.positive?
    end
    reminded
  end

  private

  def remind!(user)
    user.confirmation_reminder = true
    user.send_confirmation_instructions
    user.update_column(:confirmation_reminder_sent_at, Time.current)
  end
end
