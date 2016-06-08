include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :pin_image do
    photo_file_name { 'cat.jpg' }
    photo_content_type { 'image/jpg' }
    photo_file_size { 1024 }
    caption {Faker::Lorem.sentence(3)}
  end

  factory :real_pin_image, class: PinImage do
    photo { File.new("#{Rails.root}/spec/fixtures/cat.jpg")}
    caption {Faker::Lorem.sentence(3)}
  end
end
