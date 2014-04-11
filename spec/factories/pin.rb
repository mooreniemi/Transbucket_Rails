require 'faker'

FactoryGirl.define do
	factory :pin do |f|
		association :user
    f.id { Faker::Number.number(5) }
		f.description { Faker::Lorem.sentences(3).join(" ") }
		f.surgeon_id 1
		f.procedure_id 4
		f.user_id  { Faker::Number.number(5) }
    f.cost 3000
    f.sensation 2
    f.satisfaction 3
    f.pin_images { create_list(:pin_image, 3)}
	end

	factory :invalid_pin do |f|
    f.id { Faker::Number.number(5) }
		f.description { Faker::Lorem.sentences(3).join(" ") }
		f.surgeon_id nil
		f.procedure_id nil
		f.user_id  { Faker::Number.number(5) }
    f.cost 3000
    f.sensation 2
    f.satisfaction 3
	end
end