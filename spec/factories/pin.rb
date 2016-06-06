require 'faker'

FactoryGirl.define do
  factory :pin do
    description { Faker::Lorem.sentences(3).join(" ") }
    surgeon
    procedure
    user_id  { Faker::Number.number(5) }
    cost { Random.rand(50000) }
    sensation { Random.rand(11) }
    satisfaction { Random.rand(11) }
    pin_images { build_list(:pin_image, 2) }

    trait :with_comments do
      comments { create_list(:comment, 2) }
    end

    trait :with_surgeon_and_procedure_ids do
      surgeon_id { Faker::Number.number(5) }
      procedure_id { Faker::Number.number(5) }
    end

    trait :invalid do
      surgeon_id nil
      procedure_id nil
    end
  end
end
