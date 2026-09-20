namespace :users do
  desc "Email a reminder to unconfirmed users not yet reminded. ENV: LIMIT (default 100, hard-capped at 5000), SINCE, UNTIL (dates), DRY_RUN=true"
  task remind_unconfirmed: :environment do
    since = ENV['SINCE'] && Time.zone.parse(ENV['SINCE'])
    until_time = ENV['UNTIL'] && Time.zone.parse(ENV['UNTIL'])

    service = UnconfirmedReminderService.new(
      limit: ENV['LIMIT'] || 100,
      since: since,
      until_time: until_time
    )

    if ENV['DRY_RUN'] == 'true'
      puts "DRY_RUN: would remind #{service.scope.count} users"
    else
      reminded = service.call
      puts "Reminded #{reminded.size} users"
    end
  end
end
