FactoryGirl.define do
  factory :round do
    name {Faker::App.name}
    from_date {Faker::Time.between(DateTime.now, DateTime.now + 1)}
    end_date {Faker::Time.between(DateTime.now + 29, DateTime.now + 30)}
    status {random = ["active","open","inactive"].sample}
  end

end
