FactoryGirl.define do
	factory :comment do
		association :user
		body Faker::Lorem.paragraph
    title Faker::Lorem.sentence
	end
end