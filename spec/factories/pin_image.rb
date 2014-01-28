FactoryGirl.define do
	factory :pin_image do
		#association :pin
		#photo fixture_file_upload('/public/system/pin_images/cat.jpg', 'image/jpg')
    photo {File.new(Rails.root.join("public", "system", "pin_images", "cat.jpg"))}
    caption 'this is a caption'
    #pin_id
	end
end