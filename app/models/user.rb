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

  field :github_handle,      type: String
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
  scope :judges, -> { where(is_judge: true) }

  validates :email, :github_handle, :name, presence: true

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
      auth_token: User.encrypter.encrypt_and_sign(auth.credentials.token),
      github_user_since: auth.extra.raw_info.created_at
    })

    user.save

    # for auto_created users, we need to invoke the after_create callback.
    user.calculate_popularity unless user.current_subscription

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

  def set_royalty_bonus
    royalty_points = calculate_royalty_bonus

    if royalty_points >= USER[:royalty_points_threshold]
      self.celebrity = true
    end

    if royalty_points > 0
      self.transactions.create(points: royalty_points, transaction_type: 'royalty_bonus', type: 'credit')
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
    @_t_p ||= self.transactions.sum(:points)
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
    self.transactions.where(transaction_type: 'royalty_bonus').first
  end

  def reset_points
    if self.points > 0
      p = self.points
      self.transactions.create!(points: p, transaction_type: 'royalty_bonus', type: 'credit')
      self.transactions.create!(points: -p, transaction_type: 'redeem_points', type: 'debit')
      self.set(points: 0)
    end
  end

  def active_sponsorer_detail
    sponsorer_details.asc(:subscribed_at).where(subscription_status: :active).last
  end

  def sponsorer_detail
    sponsorer_details.asc(:subscribed_at).last
  end
end
