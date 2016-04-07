class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

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
  field :active,             type: Boolean, default: true
  field :is_judge,           type: Boolean, default: false
  field :name,               type: String
  field :provider,           type: String
  field :uid,                type: String
  field :avatar_url,         type: String
  field :points,             type: Integer, default: 0
  field :level,              type: Integer, default: 1
  field :total_points,       type: Integer, default: 0

  field :activities_count,   type: Integer, default: 0
  field :commits_count,      type: Integer, default: 0

  # Github profile info
  field :followers,          type: Integer, default: 0
  field :public_repos,       type: Integer, default: 0
  field :github_user_since,  type: Date
  field :repos_star_count,   type: Integer, default: 0

  # Sidekiq job id
  field :gh_sync_jobs,       type: Hash, default: {}

  has_many :commits, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_and_belongs_to_many :repositories, class_name: 'Repository', inverse_of: 'users'
  has_and_belongs_to_many :judges_repositories, class_name: 'Repository', inverse_of: 'judges'
  has_and_belongs_to_many :roles, inverse_of: nil
  has_many :transactions
  has_many :subscriptions
  has_many :rounds
  has_many :comments

  scope :contestants, -> { where(is_judge: false) }
  scope :judges, -> { where(is_judge: true) }

  validates :email, :github_handle, :name, presence: true

  after_create do |user|
    User.delay(queue: 'git').update_total_repos_stars(user.id)
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
      public_repos: auth.extra.raw_info.public_repos
    })

    user.save
    user
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

  def info
    @info ||= GithubClient.user(self.github_handle)
  end

  def gh_orgs
    @gh_orgs ||= GITHUB.organizations.all(user: self.github_handle)
  end

  def gh_syncing?(type)
    gh_sync_jobs[type].present?
  end

  def self.update_total_repos_stars(user_id)
    user = User.find(user_id)
    star_count = 0

    GITHUB.repositories.list(user: user.github_handle).each_page do |repos|
      star_count += repos.inject(0){|result, repo| result += repo.stargazers_count; result }
    end

    user.set(repos_star_count: star_count)
  end

  private

  def subscribe_to_latest_round
    round = Round.find_by({status: 'open'})
    if round
      round.subscriptions.create(user: self)
    end

    return true
  end
end
