FactoryGirl.define do
  factory :hackathon do
    update_interval 15

    group
    association :round, :hackathon, status: "inactive"

    factory :hackathon_with_repositories do
      transient do
        repos_count 3
      end

      after(:create) do |hackathon, evaluator|
	evaluator.repos_count.times do
	  hackathon.repositories << create(:repository_with_activity_and_commits)
	end
      end
    end
  end
end
