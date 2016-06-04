FactoryGirl.define do
  factory :comment do
    association :user
    association :commentable, factory: :pin
    body Faker::Lorem.paragraph
    title Faker::Lorem.sentence
  end

  trait :big_and_unspaced do
    body Faker::Lorem.paragraph.delete(' ')
  end
end
