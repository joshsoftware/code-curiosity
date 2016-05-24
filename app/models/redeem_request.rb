class RedeemRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :coupon_code,       type: String
  field :status,            type: Boolean, default: false
  field :points,            type: Integer

  belongs_to :user
  has_one :transaction

  index({ commit_date: -1 })

  validates :points, numericality: { only_integer: true, greater_than_or_equal_to: 50, message: 'minimum redemption limits is %{count} points.' }
  validate :check_sufficient_balance

  before_validation {|r| r.points = r.points.to_i }
  after_create :create_redeem_transaction

  protected

  def check_sufficient_balance
    if user.total_points < points
      errors.add(:points, "insufficient balance. You have only #{user.total_points} points in your account.")
    end
  end

  def create_redeem_transaction
    self.create_transaction({
      type: 'debit',
      points: points,
      transaction_type: 'redeem_points',
      user_id: user_id
    })
  end

end
