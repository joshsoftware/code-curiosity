FactoryGirl.define do
  factory :role do
    name {Faker::Name.first_name}
  end
end