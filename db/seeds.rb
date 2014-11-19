require 'factory_girl_rails'
require 'faker'

10.times do |i|
  FactoryGirl.create :pin
  puts "created ##{i} pin"
end
puts "created 10 pins"