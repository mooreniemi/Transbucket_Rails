namespace :users do
  desc "Email a password-reset link to confirmed users who've never signed in. ENV: LIMIT (default 100, hard-capped at 5000), SINCE, UNTIL (dates), DRY_RUN=true"
  task outreach_never_signed_in: :environment do
    since = ENV['SINCE'] && Time.zone.parse(ENV['SINCE'])
    until_time = ENV['UNTIL'] && Time.zone.parse(ENV['UNTIL'])

    service = NeverSignedInOutreachService.new(
      limit: ENV['LIMIT'] || 100,
      since: since,
      until_time: until_time
    )

    if ENV['DRY_RUN'] == 'true'
      puts "DRY_RUN: would contact #{service.scope.count} users"
    else
      contacted = service.call
      puts "Contacted #{contacted} users"
    end
  end
end
