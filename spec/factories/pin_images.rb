FactoryGirl.define do
	factory :pin_image do
		association :pin
		pin_image { Pin.new.pin_images.new.photo = File.open(Rails.root.join("public", "system", "pin_images", "results", "2be1.jpg")) }
	end
end