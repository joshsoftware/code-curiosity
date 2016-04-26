class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  include UserGroupHelper
  include UserGithubHelper

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
  field :name,               type: String
  field :provider,           type: String
  field :uid,                type: String
  field :avatar_url,         type: String
  field :points,             type: Integer, default: 0
  field :level,              type: Integer, default: 1
  field :auto_created,       type: Boolean, default: false

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

  has_many :commits, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_and_belongs_to_many :repositories, class_name: 'Repository', inverse_of: 'users'
  has_and_belongs_to_many :judges_repositories, class_name: 'Repository', inverse_of: 'judges'
  has_and_belongs_to_many :roles, inverse_of: nil
  has_many :transactions
  has_many :subscriptions
  has_many :rounds
  has_many :comments

  index(uid: 1)
  index(github_handle: 1)
  index(auto_created: 1)

  scope :contestants, -> { where(is_judge: false) }
  scope :judges, -> { where(is_judge: true) }

  validates :email, :github_handle, :name, presence: true

  after_create do |user|
    unless user.auto_created
      user.subscribe_to_round
      User.delay_for(2.second, queue: 'git').update_total_repos_stars(user.id.to_s)
      UserReposJob.perform_later(user)
    end
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
      auth_token: User.encrypter.encrypt_and_sign(auth.credentials.token)
    })

    user.save
    user
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

  def info
    @info ||= GITHUB.users.get(user: github_handle)
  end

  def gh_orgs
    @gh_orgs ||= GITHUB.organizations.all(user: self.github_handle)
  end

  def repo_syncing?
    last_repo_sync_at.present? && (Time.now - last_repo_sync_at) < 3600
  end

  # NOTE: If round nil the subscribe to latest round.
  def subscribe_to_round(round = nil)
    round = Round.opened unless round
    self.subscriptions.find_or_create_by(round: round) if round
  end

  def set_royalty_bonus
    royalty_points = (repos_star_count*100) * ([followers, 100].min/100.0)

    if royalty_points >= USER[:royalty_points_threshold]
      self.celebrity = true
    end

    self.transactions.create(points: royalty_points, transaction_type: 'royalty_bonus', type: 'credit')
    self.save
  end

  def self.update_total_repos_stars(user_id)
    user = User.find(user_id)
    star_count = 0

    GITHUB.repos(user: user.github_handle).list(per_page: 100).each_page do |repos|
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

  def group_name
    USER_GROUPS[level || 1]['name']
  end

  def total_points
    @_t_p ||= self.transactions.sum(:points)
  end

end
