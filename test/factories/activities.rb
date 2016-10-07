FactoryGirl.define do
  factory :activity do
    description { Faker::Lorem.sentences }
    commented_on { DateTime.now }
    association :user
    association :round
  end
end
