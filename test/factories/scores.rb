FactoryBot.define do
  factory :score do
    value { Faker::Number.number(digits: 1) }
    comment { Faker::Lorem.sentence }
    association :user
  end
end
