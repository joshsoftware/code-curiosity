FactoryGirl.define do
  factory :group_invitation do
    group nil
    token {Faker::Name.name}
    accepted_at {Faker::Date.between(5.days.ago, Date.today)}
    email {Faker::Internet.email}
  end
end
