FactoryGirl.define do
  factory :repository do
    name {Faker::Name.name}
    ssh_url { Faker::Internet.url('github.com', "/#{Faker::Lorem.word}/#{Faker::Lorem.word}") }
    source_url { Faker::Internet.url('github.com', "/#{Faker::Lorem.word}/#{Faker::Lorem.word}") }
    description { Faker::Lorem.sentence }
    watchers {Faker::Number.digit}
  end
end
