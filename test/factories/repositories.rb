FactoryGirl.define do
  factory :repository do
    source_url { Faker::Internet.url('github.com', "/#{Faker::Lorem.word}/#{Faker::Lorem.word}") }
    description { Faker::Lorem.sentence }
    watchers {Faker::Number.digit}
  end

end
