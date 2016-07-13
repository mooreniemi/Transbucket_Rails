require 'faker'

FactoryGirl.define do
  factory :pin do
    description { Faker::Lorem.sentences(3).join(" ") }
    association :surgeon, factory: :surgeon, strategy: :build
    association :procedure, factory: :procedure, strategy: :build
    user_id  { Faker::Number.number(5) }
    cost { Random.rand(50000) }
    sensation { Random.rand(5) }
    satisfaction { Random.rand(5) }
    pin_images { build_list(:pin_image, 2) }

    trait :with_comments do
      comment_threads { create_list(:comment, 2) }
    end

    trait :with_surgeon_and_procedure do
      surgeon
      procedure
    end

    trait :real_pin_image_attrs do
      pin_images { build_list(:real_pin_image, 2) }
    end

    trait :real_pin_images do
      pin_images { create_list(:real_pin_image, 2) }
    end

    trait :broken_pin_images do
      pin_images { create_list(:pin_image, 2) }
    end

    trait :invalid do
      surgeon { { id: nil } }
      procedure { { id: nil } }
    end
  end
end
