class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  field :github_handle,      type: String
  field :active,             type: Boolean, default: true
  field :is_judge,           type: Boolean, default: false
  field :name,               type: String
  field :provider,           type: String
  field :uid,                type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  has_many :commits, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_and_belongs_to_many :repositories

  scope :contestants, -> { where(is_judge: false) }

  validates :github_handle, :name, presence: true

  def self.from_omniauth(auth)  
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider       = auth.provider
      user.uid            = auth.uid
      user.email          = auth.info.email
      user.name           = auth.info.name
      user.github_handle  = auth.extra.raw_info.login
      user.password       = Devise.friendly_token[0,20]
    end
  end
end
