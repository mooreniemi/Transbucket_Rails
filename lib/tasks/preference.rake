namespace :users do
  desc "old users into new users"
  task :make_preferences => :environment do

    users = User.all
    bar = RakeProgressbar.new(users.count)

    users.each do |u|
      Preference.new(user_id: u.id).save(:validate => false)
      bar.inc
    end
    bar.finished
  end
end