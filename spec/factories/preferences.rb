FactoryGirl.define do
  factory :preference do
    user
    notification true
    safe_mode false
  end
end
