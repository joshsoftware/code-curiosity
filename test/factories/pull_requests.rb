FactoryBot.define do
  factory :pull_request do
    number             {Faker::Number.number(digits: 2)}
    comment_count      {Faker::Number.number(digits: 2)}
    author_association {"COLLABORATOR"}
    label              {"bug"}
    created_at_git     {Faker::Date.between(from: 1.month.ago, to: 2.month.ago)}
  end
end
