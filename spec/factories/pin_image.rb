include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :pin_image do
    photo { fixture_file_upload(Rails.root.join("spec", "fixtures", "cat.jpg"), 'image/jpg') }
    caption 'this is a caption'
  end
end
