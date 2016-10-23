FactoryGirl.define do
  factory :activity do
    description { Faker::Lorem.sentences }
    commented_on { DateTime.now }
    repo { 'joshsoftware/code-curiosity' }
    gh_id { '4242342342' }
    ref_url { Faker::Internet.url }
    association :user
    association :round
  end

  trait :issue do
    event_type { :issue }
  end

  trait :comment do
    event_type { :comment }
  end
end
