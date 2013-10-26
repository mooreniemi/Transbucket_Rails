# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :surgeon do
    id 1
    name "MyString"
    address "MyString"
    city "MyString"
    state "MyString"
    zip 1
    country "MyString"
    phone 1
    email "MyString"
    url "MyString"
    procedures "MyString"
  end
end
