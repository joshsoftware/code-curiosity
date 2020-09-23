FactoryBot.define do
  factory :budget do
    start_date {Date.today}
    end_date {Date.tomorrow}
    amount {Faker::Number.number(4)}
    is_all_repos {random_boolean = [true, false].sample}
  end
end
