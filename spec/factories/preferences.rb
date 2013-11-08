# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :preference, :class => 'Preferences' do
    user_id 1
  end
end
