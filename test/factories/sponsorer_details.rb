FactoryGirl.define do
  factory :sponsorer_detail do
    sponsorer_type { "INDIVIDUAL" }
    payment_plan { "base" }
    publish_profile { Faker::Boolean.boolean }
    avatar { File.new(Rails.root.join('app', 'assets', 'images', 'logo_50pxh.png')) }
    association :user

    after(:build) do |sponsor|
      helper = StripeMock.create_test_helper
      helper.create_plan(amount: 1000, name: 'base', id: 'base-individual', interval: 'month', currency: 'usd')
      token = helper.generate_card_token(last4: "4242")
      customer = Stripe::Customer.create(email: sponsor.user.email, plan: 'base-individual', source: token)
      sponsor.stripe_customer_id = customer.id
      sponsor.stripe_subscription_id = customer.subscriptions.data.first.id
      sponsor.subscribed_at = Time.at(customer.subscriptions.data.first.created).to_datetime
      sponsor.subscription_expires_at = Time.at(customer.subscriptions.data.first.current_period_end).to_datetime
      sponsor.subscription_status = customer.subscriptions.data.first.status
    end
  end
end
