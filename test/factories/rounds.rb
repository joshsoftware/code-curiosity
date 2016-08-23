FactoryGirl.define do
  factory :round do
    name {Faker::App.name}
    from_date {Faker::Time.between(DateTime.now, DateTime.now + 1)}
    end_date {Faker::Time.between(DateTime.now + 29, DateTime.now + 30)}
    status {random = ["active","open","inactive"].sample}

    trait :hackathon do
      from_date { Faker::Time.between(DateTime.now + 1, DateTime.now + 2)}
      end_date  {Faker::Time.between(DateTime.now + 3, DateTime.now + 5)}
    end

    factory :round_with_commits do
        transient do
            commits_count 1
        end
        after(:create) do |round, evaluator|
            create_list(:commit, evaluator.commits_count, :message => Faker::Lorem.sentence, round: round)
        end
    end

    factory :round_with_activities do
        transient do
            activities_count 1
        end
        after(:create) do |round, evaluator|
            create_list(:activity, evaluator.activities_count, :description => Faker::Lorem.sentence, round: round)
        end
    end

  end
end
