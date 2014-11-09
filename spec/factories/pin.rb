require 'faker'

FactoryGirl.define do
  factory :pin do
    id { Faker::Number.number(5) }
    description { Faker::Lorem.sentences(3).join(" ") }
    surgeon_id 1
    procedure_id 4
    user_id  { Faker::Number.number(5) }
    cost 3000
    sensation 2
    satisfaction 3
    pin_images { build_list(:pin_image, 3)}

    # association :user
    trait :pin_with_comments do
      association :comment, factory: :comment
    end
    trait :invalid_pin do
      surgeon_id nil
      procedure_id nil
    end
  end
end
