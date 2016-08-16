FactoryGirl.define do
  factory :subscription do
    association :user
    association :goal
    association :round
  end
end
