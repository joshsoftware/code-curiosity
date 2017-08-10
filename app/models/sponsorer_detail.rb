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

  scope :organizations, -> { where(sponsorer_type: 'ORGANIZATION') }
  scope :individuals, -> { where(sponsorer_type: 'INDIVIDUAL') }
  scope :active, -> { where(subscription_status: 'active') }
  scope :canceled, -> { where(subscription_status: 'canceled') }
  scope :publish, -> { where(publish_profile: true) }

  def save_payment_details(plan, amount, date)
    payment = self.payments.build(subscription_plan: plan, amount: amount/100, date: Time.at(date).to_datetime)
    payment.save!
    user.reset_points
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

end
