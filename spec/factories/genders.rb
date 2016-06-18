# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gender do
    sequence(:name) do |n|
      genders = ["MTF", "FTM", "GenderQueer"]
      "#{genders[n % genders.size]}#{n}"
    end
  end
end
