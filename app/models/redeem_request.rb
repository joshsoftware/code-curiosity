class RedeemRequest
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :coupon_code, type: String
  field :status,      type: Boolean, default: false
  field :points,      type: Integer
  field :amount,      type: Integer
  field :retailer,    type: String, default: REDEEM['retailers'].first
  field :store,       type: String
  field :address,     type: String
  field :gift_product_url, type: String
  field :comment, type: String

  belongs_to :user
  belongs_to :sponsorer_detail, inverse_of: :redeem_requests
  has_one :transaction, dependent: :destroy

  index({ commit_date: -1 })

  validates :retailer, inclusion: { in: REDEEM['retailers']}
  validates :points, numericality: { only_integer: true, greater_than: 0 }, unless: :retailer_other?
  validates :address, presence: true, if: :retailer_other?
  validates :gift_product_url, format: { with: URI.regexp }, if: :retailer_other?
  validate :check_sufficient_balance, unless: :retailer_other?, on: :create
  validate :points_validations, unless: :retailer_other?
  validate :redemption_points_validations, unless: :retailer_other?, on: :create
  validate :user_total_points, on: :create

  before_validation {|r| r.points = r.points.to_i }
  before_create :set_amount

  after_create do |r|
    r.create_redeem_transaction
    RedeemMailer.redeem_request(r).deliver_later
    RedeemMailer.notify_admin(r).deliver_later
  end

  after_save :send_notification

  def user_total_points
    if user.total_points == 0
      errors.add(:gift_product_url, "insufficient balance. You have only #{user.total_points} points in your account.") if retailer_other?
    end
  end

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
    royalty_points = total_royalty_points

    if royalty_points
      total_points = self.user.total_points

      #get all transactions having transaction_type as redeem_points for the user
      transactions = redeem_points_transactions

      #get redeemed_royalty_points_for_current_month, redeemed_royalty_points, redeemed_total_royalty_points
      redeemed_royalty_point, total_redeemed_royalty, redeemed_round_points = get_royalty_and_round_points(transactions)

      #threshold check is that atmost 500 royalty points can be redeemed in a month
      royalty_points_threshold_check(total_points, royalty_points, redeemed_royalty_point, total_redeemed_royalty)
    end
  end

  def create_redeem_transaction
    total_points = self.user.total_points

    self.create_transaction({
      type: 'debit',
      points: points,
      transaction_type: 'redeem_points',
      description: 'Redeem',
      user_id: user_id
    })

    #get all transactions having transaction_type as redeem_points for the user
    transactions = redeem_points_transactions
    #get redeemed_royalty_points_for_current_month, redeemed_royalty_points, redeemed_total_royalty_points
    redeemed_royalty_point, total_redeemed_royalty, redeemed_round_point = get_royalty_and_round_points(transactions)

    round_points, royalty_points = set_points(total_points, redeemed_round_point, redeemed_royalty_point)

    create_redemption_transaction(round_points, royalty_points)
  end

  def set_points(total_points, redeemed_round_point, redeemed_royalty_point)
    if total_round_points - redeemed_round_point - points >= 0
      round_points = points
      royalty_points = 0
    elsif total_royalty_points && total_royalty_points - redeemed_royalty_point - points >= 0
      round_points = total_round_points - redeemed_round_point
      royalty_points = points - round_points
    else
      round_points = total_round_points
      royalty_points = points - round_points
    end

    return [round_points, royalty_points]
  end

  def royalty_points_threshold_check(total_points, royalty_points, redeemed_royalty_point, total_redeemed_royalty)
    royalty = 0
    if total_points >= points
      # royalty point to be redeemed if round points is less than the redeemed point
      royalty = points - (total_points - royalty_points + total_redeemed_royalty) if (total_points - royalty_points + total_redeemed_royalty < points)
    end
    #shows error if
    #1 user's total_points is less than the points to be redeemed
    #2 user's total_points is greater than the points to be redeemed but royalty_points redeemed for current_months
    # are more than 500 if user is sponsorer
    #3 if user is on free plan he can only redeem 400 royalty points per month.
    royalty_points_threshold_check_as_per_user(total_points, royalty_points,
      redeemed_royalty_point, total_redeemed_royalty, royalty,
      user.is_sponsorer ? REDEEM_THRESHOLD['paid'] : REDEEM_THRESHOLD['free'])
  end

  # validating redeemption request limit for free and paid user
  # free user can redeem maximum 400 royalty_points per month.
  # paid user can redeem maximum 500 royalty points per month
  def royalty_points_threshold_check_as_per_user(total_points, royalty_points, redeemed_royalty_point, total_redeemed_royalty, royalty, threshold_points)
    if total_points < points || (total_points >= points && (royalty + redeemed_royalty_point > threshold_points))
      errors.add(:points, "at most #{threshold_points} royalty points can be redeemed in this month")
    end
  end

  def create_redemption_transaction(round_points, royalty_points)
    self.transaction.create_redemption_transaction({
      round_points: round_points,
      royalty_points: royalty_points,
      round_name: Round.opened.name
    })
  end

  def get_royalty_and_round_points(transactions)
    redeemed_royalty_point = total_redeemed_royalty = redeemed_round_point = 0

    transactions.each do |transaction|
      if transaction.redemption_transaction
        redeemed_round_point += transaction.redemption_transaction.round_points
        redeemed_royalty_point += transaction.redemption_transaction.royalty_points if Round.opened.name.eql?(transaction.redemption_transaction.round_name)
        total_redeemed_royalty += transaction.redemption_transaction.royalty_points
      end
    end

    return [redeemed_royalty_point, total_redeemed_royalty, redeemed_round_point]
  end

  def send_notification
    #return
    if coupon_code_changed? || comment_changed?
      RedeemMailer.coupon_code(self).deliver_later
    end
  end

  def total_round_points
    self.user.transactions.where(:transaction_type.in => ['GoalBonus', 'Round']).sum(:points)
  end

  def total_royalty_points
    self.user.royalty_bonus_transaction.points if self.user.royalty_bonus_transaction
  end

  def redeem_points_transactions
    self.user.transactions.where(transaction_type: 'redeem_points')
  end

  private

  def set_amount
    denominator = if sponsorer_detail
                    REDEEM['one_dollar_to_points']
                  else
                    REDEEM['one_dollar_to_points'] * 2
                  end
    self.amount = points/denominator
  end
end
