FactoryGirl.define do
  factory :score do
    value { Faker::Number.number(1) }
    comment { Faker::Lorem.sentence }
    association :user
  end
end
