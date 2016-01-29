FactoryGirl.define do
  factory :repository do    
    name {Faker::Name.name} 
    watchers {Faker::Number.digit}
    source_url {Faker::Internet.url('github.com')+"/"+Faker::Internet.user_name}
  end

end
