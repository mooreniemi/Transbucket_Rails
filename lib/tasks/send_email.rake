namespace :emails do
  desc "create genders"
  task :announce_to_recent_users => :environment do

    users = User.where("email IS NOT NULL and created_at > ?", 2.years.ago)
    bar = RakeProgressbar.new(users.count)

    users.each do |user|
      AdminMailer.announcement_email(user.email).deliver
      bar.inc
    end

    bar.finished
  end
end