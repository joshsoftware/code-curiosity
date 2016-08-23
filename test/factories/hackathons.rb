FactoryGirl.define do
  factory :hackathon do
    update_interval 15

    group
    association :round, :hackathon, status: "inactive"

    after(:create) do |hackathon, evaluator|
       hackathon.group.owner_id = hackathon.user.id
       hackathon.round.name = hackathon.group.name = "#{hackathon.user.name}'s Hackathon"
    end

    factory :hackathon_with_repositories do
      transient do
        repos_count 3
      end

      after(:create) do |hackathon, evaluator|
        create_list(:repositories, evaluator.repos_count, hackathon: hackathon)
      end
    end
  end
end
