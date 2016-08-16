FactoryGirl.define do
  factory :group do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
  end
end
