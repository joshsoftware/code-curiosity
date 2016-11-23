class RedeemRequest
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :coupon_code, type: String
  field :status,      type: Boolean, default: false
  field :points,      type: Integer
  field :retailer,    type: String, default: REDEEM['retailers'].first
  field :store,       type: String
  field :address,     type: String
  field :gift_product_url, type: String
  field :comment, type: String

  belongs_to :user
  has_one :transaction, :dependent => :destroy

  index({ commit_date: -1 })

  validates :retailer, inclusion: { in: REDEEM['retailers']}
  validates :points, numericality: { only_integer: true, greater_than: 0 }, unless: :retailer_other?
  validates :address, presence: true, if: :retailer_other?
  validates :gift_product_url, format: { with: URI.regexp }, if: :retailer_other?
  validate :check_sufficient_balance, unless: :retailer_other?, on: :create
  validate :points_validations, unless: :retailer_other?
  validate :redemption_points_validations, unless: :retailer_other?, on: :create

  before_validation {|r| r.points = r.points.to_i }

  after_create do |r|
    r.create_redeem_transaction
    RedeemMailer.redeem_request(r).deliver_later
    RedeemMailer.notify_admin(r).deliver_later
  end

  after_save :send_notification


  def self.total_points_redeemed
    where(status: true).sum(&:points)
  end

  def retailer_other?
    retailer == 'other'
  end

  def update_transaction_points
    if points.to_i > 0
      self.transaction.update(points: points)
      self.user.update(points: self.user.total_points)
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

  def redemption_points_validations
    royalty_bonus = self.user.transactions.where(transaction_type: 'royalty_bonus').first
    royalty_points = royalty_bonus.points
    total_points = self.user.total_points
    
    #shows error if
    #1 user's total_points is less than the points to be redeemed
    #2 user's total_points is greater than the points to be redeemed but royalty_points redeemed for current_months
    # are more than 500

    #redeemed_royalty_points = points + royalty_points - total_points, should not be
    #more than 500 royalty_points.
    if total_points < points || (total_points >= points && (points + royalty_points - total_points > 500))
      errors.add(:points, "at most 500 royalty points can be redeemed in this month")
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
    #return
    if coupon_code_changed? || comment_changed?
      RedeemMailer.coupon_code(self).deliver_later
    end
  end

end
