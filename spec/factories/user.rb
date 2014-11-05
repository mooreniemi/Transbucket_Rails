# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    username {Faker::Internet.user_name}
    name {Faker::Name.name}
    email {Faker::Internet.free_email}
    password {Faker::Internet.password}
  end
end
