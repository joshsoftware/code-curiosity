FactoryGirl.define do
  factory :repository do
    name { Faker::Name.name }
    ssh_url { Faker::Internet.url('github.com', "/#{Faker::Lorem.word}/#{Faker::Lorem.word}") }
    source_url { Faker::Internet.url('github.com', "/#{Faker::Lorem.word}/#{Faker::Lorem.word}") }
    description { Faker::Lorem.sentence }
    watchers { Faker::Number.digit }
    ignore { [true,false].sample }

    factory :repository_with_activity_and_commits do
      transient do
        count 2
        auto_score 2
      end

      after(:create) do |repo, evaluator|
        create_list(:commit, evaluator.count, repository: repo, auto_score: evaluator.auto_score)
        create_list(:activity, evaluator.count, repository: repo, auto_score: evaluator.auto_score)
      end
    end
  end
end
