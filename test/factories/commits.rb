FactoryGirl.define do
  factory :commit do
    commit_date { Faker::Time.between(DateTime.now - 1.hour, DateTime.now)}
    message {Faker::Lorem.paragraph}
    association :user
    association :repository
  end
end
