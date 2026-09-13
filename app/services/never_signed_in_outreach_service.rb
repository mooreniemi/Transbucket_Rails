# Emails a password-reset link to confirmed users who have never signed in
# even once -- the cohort left behind by the pre-fix confirmation flow that
# dropped people at the login page instead of signing them in. Devise's
# password-reset flow already auto-signs-in on completion
# (Devise.sign_in_after_reset_password), so this gives them the same
# one-click path back in without needing to remember a password they may
# never have used. Runs synchronously for the same reason as
# UnconfirmedReminderService: no worker dyno in production.
class NeverSignedInOutreachService
  MAX_LIMIT = 5000

  def initialize(limit: 100, since: nil, until_time: nil, sleep_between: 0.1)
    @limit = [limit.to_i, MAX_LIMIT].min
    @since = since
    @until_time = until_time
    @sleep_between = sleep_between
  end

  def scope
    users = User.where.not(confirmed_at: nil)
                .where(sign_in_count: 0)
                .where(reset_password_sent_at: nil)
    users = users.where('created_at >= ?', @since) if @since
    users = users.where('created_at <= ?', @until_time) if @until_time
    users.order(created_at: :desc).limit(@limit)
  end

  def call
    contacted = 0
    scope.to_a.each do |user|
      user.send_reset_password_instructions
      contacted += 1
      sleep @sleep_between if @sleep_between.positive?
    end
    contacted
  end
end
