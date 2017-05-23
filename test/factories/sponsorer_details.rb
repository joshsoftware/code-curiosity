FactoryGirl.define do
  factory :sponsorer_detail do
    sponsorer_type { "INDIVIDUAL" }
    payment_plan { 10 }
    publish_profile { Faker::Boolean.boolean }
    avatar { File.new(Rails.root.join('app', 'assets', 'images', 'logo_50pxh.png')) }
    association :user
  end
end
