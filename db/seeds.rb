$:.unshift File.dirname(__FILE__)

puts 'Populating genders'
require 'seeds/genders'

puts 'Populating procedures'
require 'seeds/procedures'

puts 'Populating surgeons'
require 'seeds/surgeons'

puts 'Populating users'
require 'seeds/test_users'

puts 'Populating some pins'
require 'seeds/some_pins'
