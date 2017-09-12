module SponsorerHelper
  def createStripeCustomer(email, token, plan)
    Stripe::Customer.create(
      :email => email,
      :source => token,
      :plan => plan
      )
  end

  def delete_subscription(subscription_id)
    Stripe::Subscription.retrieve(subscription_id).delete
  end
end
