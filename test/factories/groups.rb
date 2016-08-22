FactoryGirl.define do
  factory :group do 
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    members {|a| [a.association(:user)]}

    factory :group_with_invitations do
      transient do
        invitations_count 1
      end
      after(:create) do |group, evaluator|
        create_list(:group_invitation, evaluator.invitations_count, group: group)
      end
    end
    
  end
end
