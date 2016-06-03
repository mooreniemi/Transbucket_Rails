namespace :test_users do
  desc "test users for staging and dev"
  task create: :environment do
    meow_meow = User.new(email: 'bigbadmath@gmail.com',
      password: 'password',
      password_confirmation: 'password',
      username: 'meowmeow',
      name: 'AlexUser',
      gender: Gender.first).save!
    meow_meow.confirm
    puts "meowmeow user created successfully"

    zoon = User.new(email: 'mooreniemi@gmail.com',
      password: 'password',
      password_confirmation: 'password',
      username: 'zoon',
      name: 'AlexAdmin',
      gender: Gender.first,
      admin: true).save!
    zoon.confirm
    puts "zoon admin created successfully"
  end
end
