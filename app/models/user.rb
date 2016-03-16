class User
  include Mongoid::Document
  include Mongoid::Timestamps

  ROLES = {admin: 'Admin'}

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  field :github_handle,      type: String
  field :avatar_url,         type: String
  field :active,             type: Boolean, default: true
  field :is_judge,           type: Boolean, default: false
  field :name,               type: String
  field :provider,           type: String
  field :uid,                type: String
  field :points,             type: Integer, default: 0
  field :total_points,       type: Integer, default: 0
  field :level,              type: Integer, default: 1
  field :avatar_url,         type: String

  field :activities_count,   type: Integer, default: 0
  field :commits_count,      type: Integer, default: 0

  has_many :commits, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :judges_repositories, class_name: 'Repository', inverse_of: 'judges'
  has_and_belongs_to_many :roles, inverse_of: nil
  has_many :transactions
  has_many :subscriptions
  has_many :rounds
  has_many :comments

  scope :contestants, -> { where(is_judge: false) }
  scope :judges, -> { where(is_judge: true) }

  validates :email, :github_handle, :name, presence: true

  #after_create :add_signup_points_to_wallet

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.set({
        email: auth.info.email,
        name: auth.info.name,
        github_handle: auth.extra.raw_info.login,
        avatar_url: auth.info.image,
        password:  Devise.friendly_token[0,20]
      })
    end

  end

  def create_transaction(attrs = {})
    transaction = self.transactions.create(attrs)
    return false if transaction.errors.any?

    if attrs[:transaction_type] == 'credited'
      self.inc(points: attrs[:points], total_points: attrs[:total_points])
    else
      self.inc(points: -attrs[:points])
    end
  end

  def is_admin?
    roles.find_by(name: ROLES[:admin]).present?
  end

  def repo_names
    judges_repositories.map(&:name).join(",")
  end

  def score_all
    Round.all.each do |round|
      self.repositories.each do |repository|
        repository.score_commits(round)
      end
    end
  end

  private

  def add_signup_points_to_wallet
    create_transaction(type: WALLET_CONFIG['transaction_signup'], points: WALLET_CONFIG['signup_amount'], transaction_type: 'credited')
  end

end
