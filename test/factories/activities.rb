FactoryGirl.define do
  factory :activity do
    description { Faker::Lorem.sentences }
    commented_on { DateTime.now }
    association :user
    association :round

    trait :issue do
      event_type :issue
    end

    trait :comment do
      event_type :comment
    end

  end
end
