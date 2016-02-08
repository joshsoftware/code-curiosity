class Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :points, type: Integer, default: 0

  after_create :create_transaction_for_subscription

  belongs_to :user
  belongs_to :round

  def commits_count
    self.round.commits.where(user_id: self.user_id).count
  end

  def activities_count
    self.round.activities.where(user_id: self.user_id).count
  end

  private

  def create_transaction_for_subscription
    self.user.create_transaction({
      type: WALLET_CONFIG['challenge_subscription'],
      points: WALLET_CONFIG['subscription_amount'],
      transaction_type: "debited"
    })
  end

end
