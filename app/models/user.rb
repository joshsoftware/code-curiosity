class User
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create :add_signup_points_to_wallet

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable


  field :email,                         type: String, default: ""
  field :remember_created_at,           type: Time 
  field :current_sign_in_at,            type: Time 
  field :last_sign_in_at,               type: Time
  field :current_sign_in_ip,            type: String
  field :last_sign_in_ip,               type: String
  field :encrypted_password,            type: String
  field :sign_in_count,                 type: Integer, default: 0
  field :github_handle,                 type: String, default: ""
  field :active,                        type: Boolean, default: true
  field :is_judge,                      type: Boolean, default: false
  field :name,                          type: String, default: ""
  field :provider,                      type: String
  field :uid,                           type: String
  field :points,                        type: Integer , default: 0
  field :avatar_url,                    type: String , default:""

  has_many :commits, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_and_belongs_to_many :repositories
  has_many :transactions
  has_many :subscriptions
  has_many :rounds
  scope :contestants, -> { where(is_judge: false) }

  validates :email, :github_handle, :name, presence: true

  def self.from_omniauth(auth)  
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider       = auth.provider
      user.uid            = auth.uid
      user.email          = auth.info.email
      user.name           = auth.info.name
      user.github_handle  = auth.extra.raw_info.login
      user.avatar_url     = auth.extra.avatar_url
      user.password       = Devise.friendly_token.first(8)
    end

  end

  def create_transaction(attrs = {})
    self.transactions.create(attrs)
    points = attrs[:transaction_type] == 'credited' ? attrs[:points] : -attrs[:points]
    self.set(points: self.points + points) 
  end
  
  private

  def add_signup_points_to_wallet
    create_transaction(type: WALLET_CONFIG['transaction_signup'], points: WALLET_CONFIG['signup_amount'],transaction_type: "credited")
  end


end
