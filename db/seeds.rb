require 'faker'

25.times do |i|
  Pin.create(
    id: Faker::Number.number(5),
    description: Faker::Hacker.say_something_smart,
    surgeon_id: Random.rand(11),
    procedure_id: Random.rand(10),
    user_id: Faker::Number(5),
    cost: Random.rand(50000),
    sensation: Random.rand(11),
    satisfaction: Random.rand(11),
    pin_images: PinImage.create(
      photo: "",
      caption: Faker::Hacker.say_something_smart
    )
  )
  puts "created ##{i} pin"
end

puts "created 10 pins"
