class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type,              type: String
  field :points ,           type: Integer, default: 0
  field :transaction_type,  type: String

  belongs_to :user
  belongs_to :subscription
  belongs_to :redeem_request

  validates :type, :points , presence: true
  validates :type, inclusion: { in: %w(credit debit) }

  index(user_id: 1, type: 1)

  before_save do |t|
    t.points = t.credit? ? t.points.abs : -(t.points.abs)
  end

  def credit?
    type == 'credit'
  end

  def redeem_transaction?
    transaction_type == 'redeem_points'
  end

  def coupon_code
    if redeem_transaction?
      return (@ccode ||= redeem_request.coupon_code)
    end
  end

end
