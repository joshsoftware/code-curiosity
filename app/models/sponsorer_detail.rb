class SponsorerDetail
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps

  field :sponsorer_type, type: String
  field :payment_plan, type: String
  field :publish_profile, type: Boolean, default: false
  field :stripe_customer_id, type: String
  field :stripe_subscription_id, type: String
  field :subscribed_at, type: DateTime
  field :subscription_expires_at, type: DateTime
  field :subscription_status, type: String
  field :organization_url, type: String

  has_mongoid_attached_file :avatar,
    path: ':rails_root/public/system/sponsorer/:id/:style/:filename',
    url: '/system/sponsorer/:id/:style/:filename',
    :styles => { :default => "300x300>"}

  belongs_to :user
  has_many :payments, inverse_of: :sponsorer_detail, dependent: :destroy
  has_many :redeem_requests, inverse_of: :sponsorer_detail

  validates :sponsorer_type, :user, :payment_plan, presence: true
  validates :sponsorer_type, :inclusion => { :in => ['INDIVIDUAL','ORGANIZATION'] }
  validates :payment_plan, :inclusion => { :in => SPONSOR['individual'].keys }
  # validates :publish_profile, :inclusion => { :in => [true, false] }
  # validate attachment presence
  # validates_attachment_presence :avatar
  # Validate filename
  validates_attachment_file_name :avatar, matches: [/png\Z/, /jpe?g\Z/]
  # Validate content type
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  after_create :update_user_as_sponsor
  after_create :notify_user_and_admin
  after_create :update_royalty_bonus
  after_update :revert_redeem_requests, if: :subscription_status_changed?

  scope :organizations, -> { where(sponsorer_type: 'ORGANIZATION') }
  scope :individuals, -> { where(sponsorer_type: 'INDIVIDUAL') }
  scope :active, -> { where(subscription_status: 'active') }
  scope :canceled, -> { where(subscription_status: 'canceled') }
  scope :publish, -> { where(publish_profile: true) }

  def save_payment_details(plan, amount, date)
    payment = self.payments.build(subscription_plan: plan, amount: amount/100, date: Time.at(date).to_datetime)
    payment.save!
  end

  private

  def self.get_credit_card(customer_id)
    customer = Stripe::Customer.retrieve(customer_id)
    customer.sources.first
  end

  def update_user_as_sponsor
    user = self.user
    role = Role.find_or_create_by(name: 'Sponsorer')
    user.roles << role unless user.is_sponsorer?
    user.set({is_sponsorer: true})
  end

  def notify_user_and_admin
    SponsorMailer.notify_subscriber(user_id.to_s, payment_plan, SPONSOR[sponsorer_type.downcase][payment_plan]).deliver_later
    SponsorMailer.notify_admin(user_id.to_s, payment_plan, SPONSOR[sponsorer_type.downcase][payment_plan]).deliver_later
  end

  # update worth of royalty points of user if user took subscription within 1 month after
  # signup to code curiosity
  # first condition prevents transaction amount update when user create multiple subscriptions within 1 month after sign up
  def update_royalty_bonus
    if (user.sponsorer_details.count == 1) && (self.created_at - user.created_at <= 1.month) && (user.transactions.where(transaction_type: 'royalty_bonus').any?)
      transaction = user.transactions.find_by transaction_type: 'royalty_bonus'
      transaction.set(amount: transaction.points.to_f/SUBSCRIPTIONS[user.sponsorer_detail.sponsorer_type.downcase])
    end
  end

  # if user cancel his sponsorship this method will revert all his active redeem requests
  # which he made during his sponsorship
  def revert_redeem_requests
    if subscription_status == 'canceled'
      redeem_requests = user.redeem_requests.where(:created_at.gte => created_at, :created_at.lte => updated_at, status: false)
      redeem_requests.destroy_all
    end
  end
end
