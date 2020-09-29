FactoryBot.define do
  factory :user do
    name {Faker::Name.name}
    email { Faker::Internet.email }
    password {Faker::Internet.password}
    sign_in_count {Faker::Number.digit}
    active {random_boolean = [true, false].sample}
    is_judge {random_boolean = [true, false].sample}
    github_handle {Faker::Internet.user_name}
    uid { Faker::Number.number(digits: 6) }

    factory :user_with_transactions do
        transient do
            transactions_count {1}
        end
        after(:create) do |user, evaluator|
            create_list(:transaction, evaluator.transactions_count, :points => 1, :type => 'credit', user: user)
        end
    end
  end
end
