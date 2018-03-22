FactoryGirl.define do
  factory :offer do
    name {Faker::Name.name}
    email { Faker::Internet.email }
    active_from Date.today.beginning_of_month
    active_till Date.today.end_of_month
  end
end
