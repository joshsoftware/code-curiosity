class RedeemRequest
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :coupon_code, type: String
  field :status,      type: Boolean, default: false
  field :points,      type: Integer
  field :retailer,    type: String, default: RETAILERS.first
  field :address,     type: String
  field :gift_product_url, type: String

  belongs_to :user
  has_one :transaction

  index({ commit_date: -1 })

  validates :retailer, presence: true
  validates :gift_product_url, format: { with: URI.regexp }, allow_blank: true
  validates :points, numericality: { only_integer: true, greater_than_or_equal_to: 50, message: 'minimum redemption limits is %{count} points.' }
  validate :check_sufficient_balance

  before_validation {|r| r.points = r.points.to_i }
  after_create do |r|
    r.create_redeem_transaction
    redeemMailer.redeem_request(r).deliver_later
  end

  after_save :send_coupon_code

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
      description: 'Redeem',
      user_id: user_id
    })
  end

  def send_coupon_code
    if coupon_code_changed?
      RedeemMailer.coupon_code(self).deliver_later
    end
  end

end
