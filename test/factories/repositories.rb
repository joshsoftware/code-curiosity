FactoryBot.define do
  factory :repository do
    name {Faker::Name.name}
    ssh_url { Faker::Internet.url(host: 'github.com', path: "/#{Faker::Lorem.word}/#{Faker::Lorem.word}") }
    source_url { Faker::Internet.url(host: 'github.com', path: "/#{Faker::Lorem.word}/#{Faker::Lorem.word}") }
    description { Faker::Lorem.sentence }
    watchers {Faker::Number.digit}
    gh_id {Faker::Number.number(digits: 6)}

    factory :repository_with_activity_and_commits do
      transient do
        count {2}
        score {2}
      end

      after(:create) do |repo, evaluator|
        create_list(:commit, evaluator.count, repository: repo, score: evaluator.score)
        create_list(:activity, evaluator.count, repository: repo, score: evaluator.score)
      end
    end
  end
end
