class Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  
  after_create :deduct_points_from_user_wallet 

  belongs_to :user
  belongs_to :round
  private
  

  def deduct_points_from_user_wallet
      self.user.create_transaction({
        type: WALLET_CONFIG['challenge_subscription'], 
        points: WALLET_CONFIG['subscription_amount'],
        transaction_type: "debited"
      })
  end

end
