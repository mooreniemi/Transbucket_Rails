namespace :test_users do
  desc "test users for staging and dev"
  task create: :environment do
    doodle = User.new(email: 'doodle.doo@foo.com',
      password: 'password',
      password_confirmation: 'password',
      username: 'doodle',
      name: 'DoodleDoo',
      gender: Gender.last)
		doodle.skip_confirmation!
		doodle.save!
    puts "doodle user created successfully"

    skeeter = User.new(email: 'skeeter@foo.com',
      password: 'password',
      password_confirmation: 'password',
      username: 'skeeter',
      name: 'Skeeter',
      gender: Gender.last)
		skeeter.skip_confirmation!
		skeeter.save!
    puts "skeeter user created successfully"

    shitty_cat = User.new(email: 'shitty_cat@cats.com',
      password: 'password',
      password_confirmation: 'password',
      username: 'shitty_cat',
      name: 'Koko',
      gender: Gender.last)
		shitty_cat.skip_confirmation!
		shitty_cat.save!
    puts "shitty_cat user created successfully"
  end
end
