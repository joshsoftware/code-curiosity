FactoryGirl.define do
  factory :role do
    name {Faker::Name.first_name}

    trait :admin do
      name 'Admin'
    end

  end
end
