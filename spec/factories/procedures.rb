FactoryGirl.define do
  factory :procedure do
    name { Faker::Lorem.words(2).join(" ") }
    gender { ["MTF", "FTM"].sample }
    body_type { ["Top", "Bottom", "Face", "Other"].sample }
    avg_sensation 3
    avg_satisfaction 3
  end
  trait :uncomputed do
    avg_sensation nil
    avg_satisfaction nil
  end
end
