class User
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create :add_signup_points_to_wallet

  devise  :authenticatable,:rememberable,  :omniauthable

  field :email,              type: String, default: ""

  ## Rememberable
  field :remember_created_at, type: Time

  field :sign_in_count,      type: Integer, default: 0
  field :github_handle,      type: String, default: ""
  field :active,             type: Boolean, default: true
  field :is_judge,           type: Boolean, default: false
  field :name,               type: String, default: ""
  field :provider,           type: String
  field :uid,                type: String
  field :points,             type: Integer , default: 0

  has_many :commits, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_and_belongs_to_many :repositories
  has_many :transactions

  scope :contestants, -> { where(is_judge: false) }

  validates :email, :github_handle, :name, presence: true

  def self.from_omniauth(auth)  
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider       = auth.provider
      user.uid            = auth.uid
      user.email          = auth.info.email
      user.name           = auth.info.name
      user.github_handle  = auth.extra.raw_info.login
    end

  end

  private

  def add_signup_points_to_wallet
    self.transactions.create(type:WALLET_CONFIG['wallet']['transaction_signup'], points:WALLET_CONFIG['wallet']['signup_amount'])
    self.points = WALLET_CONFIG['wallet']['signup_amount']
  end
end
