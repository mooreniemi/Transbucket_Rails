FactoryGirl.define do
  factory :pin_image do
    photo {File.new(Rails.root.join("spec", "fixtures", "cat.jpg"))}
    caption 'this is a caption'
  end
end
