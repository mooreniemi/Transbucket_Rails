namespace :legacy do
  desc "Migrate legacy data"
  task :migrate => :environment do   # The => :environment does the work of loading your Rails environment so you can use ActiveRecord, etc.
    require 'models/legacy_models/migrater'   # Require your migration class

    # You can pass values from the command line rake call (e.g. rake legacy:migrate MODEL=LegacyUser START_ROW=500) 
    # as a hash to your migration script using the ENV variable
    migrater = Migrater.new(ENV)
    migrater.go!
  end
end