FactoryGirl.define do
  factory :activity do
    description {Faker::Lorem.sentences}
    association :user
    association :round
  end
end
