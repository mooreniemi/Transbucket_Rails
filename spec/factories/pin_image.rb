FactoryGirl.define do
	factory :pin_image do
		association :pin
		photo
    caption
    pin_id
	end
end