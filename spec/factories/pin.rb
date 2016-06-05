require 'faker'

FactoryGirl.define do
  factory :pin do
    id { Faker::Number.number(5) }
    description { Faker::Lorem.sentences(3).join(" ") }
    surgeon_id { Random.rand(11) }
    procedure_id { Random.rand(10) }
    user_id  { Faker::Number.number(5) }
    cost { Random.rand(50000) }
    sensation { Random.rand(11) }
    satisfaction { Random.rand(11) }
    pin_images { build_list(:pin_image, 2)}

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
