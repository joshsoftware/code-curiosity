class Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  
  after_create :create_transaction_for_subscription 

  belongs_to :user
  belongs_to :round

  private
  
  def create_transaction_for_subscription
      self.user.create_transaction({
        type: WALLET_CONFIG['challenge_subscription'], 
        points: WALLET_CONFIG['subscription_amount'],
        transaction_type: "debited"
      })
  end

end
