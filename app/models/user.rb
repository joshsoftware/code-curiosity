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

  belongs_to :goal
  has_many :commits, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :rounds
  has_many :comments, dependent: :destroy
  has_many :redeem_requests, dependent: :destroy
  has_many :group_invitations, dependent: :destroy
  has_and_belongs_to_many :repositories, class_name: 'Repository', inverse_of: 'users'
  has_and_belongs_to_many :judges_repositories, class_name: 'Repository', inverse_of: 'judges'
  has_and_belongs_to_many :roles, inverse_of: nil
  has_and_belongs_to_many :organizations
  has_and_belongs_to_many :groups, class_name: 'Group', inverse_of: 'members'
  has_many :sponsorer_details, dependent: :destroy

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
  after_create do |user|
    user.calculate_popularity unless user.auto_created
  end

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

    # for auto_created users, we need to invoke the after_create callback.
    user.calculate_popularity unless user.current_subscription

    if Offer.is_winner?(user)
      user.upgrade_account unless user.active_sponsorer_detail
    end

    user
  end

  def calculate_popularity
    self.subscribe_to_round
    User.delay_for(2.second, queue: 'git').update_total_repos_stars(self.id.to_s)
    UserReposJob.perform_later(self.id.to_s)
  end

  def create_transaction(attrs = {})
    transaction = self.transactions.create(attrs)
    return false if transaction.errors.any?

    if attrs[:transaction_type] == 'credited'
      self.inc(points: attrs[:points])
    else
      self.inc(points: -attrs[:points])
    end
  end

  def is_admin?
    roles.where(name: ROLES[:admin]).any?
  end

  def is_sponsorer?
    roles.where(name: 'Sponsorer').any?
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

  def repo_syncing?
    last_repo_sync_at.present? && (Time.now - last_repo_sync_at) < 3600
  end

  def gh_data_syncing?
    last_gh_data_sync_at.present? && (Time.now - last_gh_data_sync_at) < 3600
  end

  def subscribe_to_round(round = nil)
    round = round || Round.opened
    return false unless round

    last_subscription = subscriptions.desc(:created_at).first

    subscriptions.find_or_create_by(round: round) do |subscription|
      subscription.goal = self.goal || last_subscription.try(:goal)
    end
  end

  def calculate_royalty_bonus
    (repos_star_count * ([followers, 100].min/100.0)).round
  end

  # Set the royalty bonus(RB) for a user based on the rating of the repositories owned.
  # If the user signs up for the first time and if the RB is 450, credit 450 points to the user.
  # If the user deletes his/her account and re-signs-up and if the calculated RB is 600, credit only 150 (ie. 600-450).
  # If the user signs up for the first time and RB is 450,  and has earned 900 for the first round, his total points are 1350.
  # If he deletes and re-signs-up with 550 RB, the new transaction of RB would be of 100(550-450) and total points would be 1450.
  # The points earned via commits and activities and redeem requests of the user are already tracked via the transactions
  # and hence need not be considered while calculating the royalty points.
  def set_royalty_bonus
    royalty_points = calculate_royalty_bonus

    if royalty_points >= USER[:royalty_points_threshold]
      self.celebrity = true
    end

    if royalty_points > 0
      self.transactions.create(points: royalty_points, transaction_type: 'royalty_bonus', type: 'credit')
=begin
      royalty_bonuses = self.transactions.where(transaction_type: 'royalty_bonus', type: 'credit')
      self.transactions.create(
        points: royalty_bonuses.any? ? royalty_points - royalty_bonuses.sum(:points) : royalty_points,
        transaction_type: 'royalty_bonus', type: 'credit'
      )
=end
    end

    self.points = royalty_points
    self.save
  end

  def self.update_total_repos_stars(user_id)
    user = User.find(user_id)
    star_count = 0

    user.gh_client.repos(user: user.github_handle).list(per_page: 100).each_page do |repos|
      repos.each do |repo|
        if repo.stargazers_count >= REPOSITORY_CONFIG['popular']['stars']
          star_count += repo.stargazers_count
        end
      end
    end

    user.set(repos_star_count: star_count)
    user.set_royalty_bonus
  end

  def self.encrypter
    @_encrypter ||= ActiveSupport::MessageEncryptor.new(Base64.decode64(ENV['ENC_KEY']))
  end

  def total_points
    self.transactions.sum(:points)
  end

  def current_subscription(round = nil)
    round = Round.opened unless round
    @_csu ||= subscriptions.where(round_id: round.id).first
  end

  def self.search(q)
    User.where(github_handle: /^#{q}/i).limit(8).pluck(:github_handle, :id, :avatar_url)
  end

  def able_to_redeem?
    (github_user_since <= Date.today - 6.months) && (created_at <= Date.today - 3.months)
  end

  def royalty_bonus_transaction
    self.transactions.where(transaction_type: 'royalty_bonus').asc(:created_at).first
  end

  def active_sponsorer_detail
    sponsorer_details.asc(:subscribed_at).where(subscription_status: :active).asc(:created_at).last
  end

  def deleted?
    self.deleted_at.present? and !active
  end

  def sponsorer_detail
    sponsorer_details.asc(:created_at).last
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


  def upgrade_account
    sponsorer_details.create(
      sponsorer_type: 'INDIVIDUAL',
      subscription_status: 'active',
      payment_plan:  SPONSOR['individual'].keys.first,
    )
  end
end
