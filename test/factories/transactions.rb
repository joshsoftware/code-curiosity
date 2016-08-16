FactoryGirl.define do
  factory :transaction do
    type {Faker::Lorem.word}
    points {Faker::Number.number(2)}
    association :user 
  end
end
