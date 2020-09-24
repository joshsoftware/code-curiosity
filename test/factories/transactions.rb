FactoryBot.define do
  factory :transaction do
    type {Faker::Lorem.word}
    points {Faker::Number.number(digits: 2)}
    association :user 
  end
end
