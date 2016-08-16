FactoryGirl.define do
  factory :activity do
    description {Faker::Lorem.sentences}
    association :user
  end
end