$:.unshift File.dirname(__FILE__)

puts 'Populating genders'
require 'seeds/genders'

puts 'Populating procedures'
require 'seeds/procedures'

puts 'Populating surgeons'
require 'seeds/surgeons'

require 'seeds/test_users'
require 'seeds/some_pins'
