# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :surgeon do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name.gsub("'", "") }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip_code }
    country { Faker::Address.country }
    phone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    url { Faker::Internet.url }
    procedure_list { Faker::Lorem.words.join(',') }
  end
end
