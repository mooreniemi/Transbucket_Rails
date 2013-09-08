require 'faker'

FactoryGirl.define do
	factory :pin do |f|
		f.description { Faker::Lorem.sentences(5).join(" ") }
		f.surgeon { Faker::Name.last_name }
		f.procedure "T Anchor Double Incision"
		f.user_id { Faker::PhoneNumber.cell_phone}
		#f.pin_images {Pin.new.pin_images.new.photo = File.open(Rails.root.join("public", "system", "pin_images", "results", "2be1.jpg"))}
	end

	factory :invalid_pin do |f|
		f.description { Faker::Lorem.sentences(5).join(" ") }
		f.surgeon { Faker::Name.last_name }
		f.surgeon nil
		f.user_id { Faker::PhoneNumber.cell_phone}
	end
end