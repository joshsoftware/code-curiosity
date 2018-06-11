FactoryGirl.define do
  factory :sponsor do
    name {Faker::Name.name}
    is_individual {random_boolean = [true, false].sample}
  end
end
