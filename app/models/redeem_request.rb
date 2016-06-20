class RedeemRequest
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :coupon_code, type: String
  field :status,      type: Boolean, default: false
  field :points,      type: Integer
  field :retailer,    type: String, default: REDEEM['retailers'].first
  field :address,     type: String
  field :gift_product_url, type: String
  field :comment, type: String

  belongs_to :user
  has_one :transaction

  index({ commit_date: -1 })

  validates :retailer, inclusion: { in: REDEEM['retailers']}
  validates :points, numericality: { only_integer: true, greater_than: 0 }, unless: :retailer_other?
  validates :address, presence: true, if: :retailer_other?
  validates :gift_product_url, format: { with: URI.regexp }, if: :retailer_other?
  validate :check_sufficient_balance, unless: :retailer_other?
  validate :points_validations, unless: :retailer_other?

  before_validation {|r| r.points = r.points.to_i }

  after_create do |r|
    r.create_redeem_transaction
    RedeemMailer.redeem_request(r).deliver_later
  end

  after_save :send_notification

  def retailer_other?
    retailer == 'other'
  end

  def update_transaction_points
    if points.to_i > 0
      self.transaction.update(points: points)
    end
  end

  protected

  def check_sufficient_balance
    if user.total_points < points
      errors.add(:points, "insufficient balance. You have only #{user.total_points} points in your account.")
    end
  end

  def points_validations
    if retailer == 'amazon'
      if points.to_i == 0 || points.to_i % REDEEM['min_points'] != 0
        errors.add(:points, "points must be in multiple of #{REDEEM['min_points']}")
      end
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

  def send_notification
    return
    if coupon_code_changed? || comment_changed?
      binding.pry
      RedeemMailer.coupon_code(self).deliver_later
    end
  end

end
