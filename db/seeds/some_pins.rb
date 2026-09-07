require 'faker'

PIN_COUNT = 250
REAL_IMAGE_PATH = Rails.root.join("app", "assets", "images", "dysphoria.jpg")

users = User.all.to_a
surgeons = Surgeon.all.to_a
procedures = Procedure.all.to_a

PIN_COUNT.times do |i|
  File.open(REAL_IMAGE_PATH, "rb") do |photo|
    Pin.create!(
    description: Faker::Hacker.say_something_smart,
    details: Faker::Hacker.say_something_smart,
    surgeon_id: surgeons.sample.id,
    procedure_id: procedures.sample.id,
    user_id: users.sample.id,
    cost: Random.rand(50000),
    sensation: Random.rand(5),
    satisfaction: Random.rand(5),
    pin_images: [
      PinImage.create!(
        photo: photo,
        caption: Faker::Hacker.say_something_smart
      )
    ]
  )
  end
end

puts "created #{PIN_COUNT} pins"
