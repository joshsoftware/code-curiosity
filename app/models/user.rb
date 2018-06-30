class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  include UserGithubHelper
  include Mongoid::Slug
  ROLES = {admin: 'Admin'}

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable
  devise :database_authenticatable,
    :rememberable, :trackable, :validatable, :omniauthable

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
  field :blocked,            type: Boolean, default: false

  field :github_handle,      type: String
  field :twitter_handle,     type: String
  field :active,             type: Boolean, default: true
  field :is_judge,           type: Boolean, default: false
  field :is_sponsorer,       type: Boolean, default: false
  field :name,               type: String
  field :provider,           type: String
  field :uid,                type: String
  field :avatar_url,         type: String
  field :points,             type: Integer, default: 0
  field :level,              type: Integer, default: 1
  field :auto_created,       type: Boolean, default: false
  field :notify_monthly_progress,    type: Boolean, default: true
  field :notify_monthly_points,    type: Boolean, default: true

  field :activities_count,   type: Integer, default: 0
  field :commits_count,      type: Integer, default: 0
  field :celebrity,          type: Boolean, default: false

  # Github profile info
  field :followers,          type: Integer, default: 0
  field :public_repos,       type: Integer, default: 0
  field :github_user_since,  type: Date
  field :repos_star_count,   type: Integer, default: 0
  field :auth_token,         type: String

  # Background sync
  field :last_repo_sync_at,  type: Time
  field :last_gh_data_sync_at, type: Time

  # User account deletion
  field :deleted_at, type: Time

  # for accepting terms and conditions
  field :terms_and_conditions, type: Boolean, default: false

  # for language wise badges
  field :badges, type: Hash, default: {}

  has_many :commits, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :redeem_requests, dependent: :destroy
  has_and_belongs_to_many :repositories, class_name: 'Repository', inverse_of: 'users'
  has_and_belongs_to_many :roles, inverse_of: nil

  slug  :github_handle

  index(uid: 1)
  index(github_handle: 1)
  index(auto_created: 1)

  scope :contestants, -> { where(auto_created: false) }
  scope :blocked,   -> { where(blocked: true) }
  scope :allowed,   -> { where(blocked: false) }
  scope :judges, -> { where(is_judge: true) }

  validates :email, :github_handle, :name, :uid, presence: true
  validates :uid, uniqueness: true
  validates :twitter_handle, presence: true, format: { with: /\A@\w{1,15}\z/, message: "invalid Twitter handle"}, allow_nil: true

  before_validation :append_twitter_prefix

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.password = Devise.friendly_token[0, 20]
    end

    user.set({
      email: auth.info.email,
      name: auth.info.name,
      avatar_url: auth.info.image,
      github_handle: auth.extra.raw_info.login,
      followers: auth.extra.raw_info.followers,
      public_repos: auth.extra.raw_info.public_repos,
      auto_created: false,
      github_user_since: auth.extra.raw_info.created_at,
      deleted_at: nil,
      active: true,
      auth_token: User.encrypter.encrypt_and_sign(auth.credentials.token)
    })

    user.save
    user
  end

  def create_transaction(attrs = {})
    transaction = self.transactions.create(attrs)
    return false if transaction.errors.any?

    if attrs[:type] == 'credit'
      self.inc(points: attrs[:points])
    else
      self.inc(points: -attrs[:points])
    end
  end

  def is_admin?
    roles.where(name: ROLES[:admin]).any?
  end

  def repo_names
    judges_repositories.map(&:name).join(",")
  end

  def repo_syncing?
    last_repo_sync_at.present? && (Time.now - last_repo_sync_at) < 3600
  end

  def gh_data_syncing?
    last_gh_data_sync_at.present? && (Time.now - last_gh_data_sync_at) < 3600
  end

  def self.encrypter
    @_encrypter ||= ActiveSupport::MessageEncryptor.new(Base64.decode64(ENV['ENC_KEY']))
  end

  def redeemable_points
    transactions.redeemable.sum(:points)
  end

  def self.search(q)
    User.where(github_handle: /^#{q}/i).limit(8).pluck(:github_handle, :id, :avatar_url)
  end

  def able_to_redeem?
    (github_user_since <= Date.today - 6.months) && (created_at <= Date.today - 3.months)
  end

  def deleted?
    self.deleted_at.present? and !active
  end

  def append_twitter_prefix
    if self.twitter_handle.present?
      self.twitter_handle.strip!
      # Regex to match whether twitter handle provided by user contains @ sign at its
      # begining or not
      if !/^@/.match(self.twitter_handle)
        self.twitter_handle = '@' + self.twitter_handle
      end
    end
  end
end
