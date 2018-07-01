class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  TRANSACTION_TYPES = ['royalty_bonus', 'Round', 'GoalBonus', 'daily reward']

  field :type,              type: String
  field :points ,           type: Integer, default: 0
  field :transaction_type,  type: String
  field :description,       type: String
  field :amount,            type: Float, default: 0.0
  field :hidden,            type: Boolean, default: false

  belongs_to :user
  belongs_to :redeem_request

  validates :type, :points , presence: true
  validates :type, inclusion: { in: %w(credit debit) }

  index(user_id: 1, type: 1)
  index(transaction_type: 1)

  scope :redeemable, -> { where(:created_at.gte => NEW_FEATURE_LAUNCH_DATE) }
  scope :credited, -> (types) { where(:transaction_type.in => types) }

  before_save do |t|
    t.points = t.credit? ? t.points.abs : -(t.points.abs)
    t.amount = t.credit? ? t.amount.abs : -(t.amount.abs)
  end

  after_create :set_amount

  def credit?
    type == 'credit'
  end

  def redeem_transaction?
    transaction_type == 'redeem_points'
  end

  def coupon_code
    if redeem_transaction?
      return (@ccode ||= redeem_request.try(:coupon_code))
    end
  end

  def self.total_points_before_redemption
    Transaction.credited(TRANSACTION_TYPES).sum(:points)
  end

  def self.total_points_redeemed
    Transaction.where(transaction_type: 'redeem_points').sum(:points).abs
  end

  def set_amount
    set(amount: points.to_f)
  end
end
