module SponsorerHelper
  def createStripeCustomer(email, token)
    Stripe::Customer.create(
      :email => email,
      :source => token
      )
  end

  def createStripeSubscription(customer_id, plan_id)
    Stripe::Subscription.create(
      :customer => customer_id,
      :plan => plan_id
      )
  end
end