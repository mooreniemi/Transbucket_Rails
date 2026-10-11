class HealthMailer < ActionMailer::Base
  ADMIN = "admin@transbucket.com"
  default from: ADMIN

  def alert(failing)
    @failing = failing
    mail(to: ENV['HEALTH_ALERT_EMAIL'].presence || ADMIN,
         subject: "[Transbucket health] failing: #{failing.join(', ')}")
  end
end
