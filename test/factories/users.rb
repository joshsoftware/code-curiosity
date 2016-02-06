FactoryGirl.define do
  factory :user do
    name {Faker::Name.name}
    email { Faker::Internet.email }
    password {Faker::Internet.password}
    sign_in_count {Faker::Number.digit}
    active {random_boolean = [true, false].sample}
    is_judge {random_boolean = [true, false].sample}
    github_handle {Faker::Internet.user_name}
  end
end
