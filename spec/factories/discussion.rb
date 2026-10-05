FactoryBot.define do
  factory :discussion do
    association :user
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    visibility { 'everyone' }
    category { 'discussion' }
  end
end
