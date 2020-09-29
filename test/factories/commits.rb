FactoryBot.define do
  factory :commit do
    message { Faker::Lorem.paragraph }
    commit_date { DateTime.now }
    association :user
    association :repository
  end
end
