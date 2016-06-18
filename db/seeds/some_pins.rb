require 'faker'

PIN_COUNT = 25
PIN_COUNT.times do |i|
  Pin.create(
    id: Faker::Number.number(5),
    description: Faker::Hacker.say_something_smart,
    surgeon_id: Random.rand(11),
    procedure_id: Random.rand(10),
    user_id: Faker::Number.number(5),
    cost: Random.rand(50000),
    sensation: Random.rand(5),
    satisfaction: Random.rand(5),
    pin_images: [
      PinImage.create(
        photo: "",
        caption: Faker::Hacker.say_something_smart
      )
  ]
  )
end

puts "created #{PIN_COUNT} pins"
