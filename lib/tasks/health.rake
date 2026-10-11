namespace :health do
  desc "Email an alert if sign-ups, logins or signed-in browsing have stopped. Meant for Heroku Scheduler; ENV HEALTH_ALERT_EMAIL overrides the recipient"
  task check: :environment do
    check = AuthHealthCheck.new
    if check.healthy?
      puts "health ok"
    else
      puts "health failing: #{check.failing.join(', ')}"
      HealthMailer.alert(check.failing).deliver_now
    end
  end
end
