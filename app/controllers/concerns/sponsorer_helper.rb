module SponsorerHelper
  def createStripeCustomer(email, token, plan)
    Stripe::Customer.create(
      :email => email,
      :source => token,
      :plan => plan
      )
  end
end