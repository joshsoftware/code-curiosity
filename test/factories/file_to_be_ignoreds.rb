FactoryBot.define do
  factory :file_to_be_ignored do
    name {Faker::Lorem.word}
    programming_language {Faker::Lorem.word}
  end
end
