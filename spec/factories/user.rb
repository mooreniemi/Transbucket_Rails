FactoryBot.define do
  factory :user do
    sequence(:username) {|n| "#{Faker::Internet.user_name}_#{n}" }
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    gender

    trait :wants_notifications do
      preference
    end

    trait :with_confirmation do
      after(:create) do |user|
        user.skip_confirmation!
        user.save!
      end
    end
  end
end
