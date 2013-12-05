# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :procedure do
    id { Faker::Number.number(3)}
    name { Faker::Lorem.words(2) }
    gender { Faker::Lorem.word }
    body_type { Faker::Lorem.word }
    avg_sensation 3
    avg_satisfaction 3
  end
end
