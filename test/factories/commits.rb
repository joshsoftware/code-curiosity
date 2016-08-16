FactoryGirl.define do
  factory :commit do
    message {Faker::Lorem.paragraph}
    association :user
    association :repository
  end
end