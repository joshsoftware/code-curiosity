FactoryGirl.define do
  factory :comment do
    content "MyString"
    association :user
  end

end
