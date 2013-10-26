# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    id 1
    username "username"
    name "MyString"
    email "My@String.com"
    gender
  end
end
