class Repository
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  include RepoLeaders
  include Mongoid::Paranoia

  field :name,         type: String
  field :description,  type: String
  field :stars,        type: Integer, default: 0
  field :watchers,     type: Integer, default: 0
  field :forks,        type: Integer, default: 0
  field :owner,        type: String
  field :source_url,   type: String
  field :gh_id,        type: Integer
  field :source_gh_id, type: Integer
  field :languages,    type: Array
  field :ssh_url,      type: String
  field :ignore_files, type: Array, default: []
  field :type,         type: String
  field :ignore,       type: Boolean, default: false
  field :branches,     type: Array, default: ['master']

  belongs_to :popular_repository, class_name: 'Repository', inverse_of: 'repositories'
  belongs_to :organization
  has_many :commits
  has_many :activities
  has_many :code_files
  has_many :repositories, class_name: 'Repository', inverse_of: 'popular_repository'
  has_and_belongs_to_many :users, class_name: 'User', inverse_of: 'repositories'
  has_and_belongs_to_many :judges, class_name: 'User', inverse_of: 'judges_repositories'

  validates :name, :source_url, :ssh_url, presence: true
  #validate :verify_popularity

  index(source_url: 1)
  index({ gh_id: 1 }, { unique: true })

  scope :popular, -> { where(type: 'popular') }
  scope :users_repos, -> { where(:type.ne =>  'popular') }
  scope :required, -> { where(ignore: false) }
  scope :parent, -> { any_of({type: 'popular'}, {source_gh_id: nil, popular_repository_id: nil})}
  def popular?
    self.type == 'popular'
  end

  def verify_popularity
    minimum_stars = REPOSITORY_CONFIG['popular']['stars']

    if popular_repository
      if popular_repository.stars < minimum_stars
        self.errors.add(:base, I18n.t('repositories.contribute_to', stars: minimum_stars))
      end
    elsif stars < minimum_stars
      self.errors.add(:base, I18n.t('repositories.contribute_to', stars: minimum_stars))
    end
  end

  def info
    @info ||= GITHUB.repos.get(owner, name, {redirection: true})
  end

  def self.add_new(params, user)
    repo = Repository.where(gh_id: params[:gh_id]).first

    if repo
      repo.users << user unless repo.users.include?(user)
      return repo
    end

    gh_repo = user.gh_client.repos.get(params[:owner], params[:name])
    return unless gh_repo

    repo = build_from_gh_info(gh_repo)

    if gh_repo.fork
      return repo if gh_repo.source.stargazers_count < REPOSITORY_CONFIG['popular']['stars']

      popular_repo = Repository.popular.where(gh_id: gh_repo.source.id).first || build_from_gh_info(gh_repo.source)
      popular_repo.type = 'popular'
      popular_repo.save
      repo.popular_repository = popular_repo
    else
      return repo if gh_repo.stargazers_count < REPOSITORY_CONFIG['popular']['stars']
    end

    self.create_repo_owner_account(gh_repo.fork ? gh_repo.source : gh_repo)

    user.repositories << repo
    return repo
  end

  def self.build_from_gh_info(info)
    Repository.new({
      name: info.name,
      source_url: info.html_url,
      description: info.description,
      watchers: info.watchers_count,
      stars: info.stargazers_count,
      forks: info.forks_count,
      languages: [ info.language],
      gh_id: info.id,
      ssh_url: info.ssh_url,
      owner: info.owner.login
    })
  end

  def self.create_repo_owner_account(repo)
    return unless repo.owner.type == 'User'

    user = User.find_or_initialize_by(provider: 'github', uid: repo.owner.id)

    return user if user.persisted?

    user.github_handle = repo.owner.login
    user.avatar_url = repo.owner.avatar_url
    user.password = Devise.friendly_token[0, 20]
    user.auto_created = true
    user.save(validate: false)
    user
  end

  def repository_uri
    self.source_url.to_s.sub(/(https|http):\/\/github.com\//, '')
  end

  def judges_name
    judges.map(&:github_handle).join(",")
  end

  def git
    @git ||= Git.open(code_dir)
  end

  PULL_REQ_MERGE_REGX = /merge (pull|branch)/i

  def score_commits(round = nil)
    engine = ScoringEngine.new(self)

    _commits = self.commits.where(auto_score: nil)
    _commits = _commits.where(round: round) if round

    _commits.each do |commit|
      if commit.message =~ PULL_REQ_MERGE_REGX
        commit.set(auto_score: 0)
      else
        begin
          Sidekiq.logger.info "Scoring for commit: #{commit.id}, Round: #{round.from_date}"
          # commit.set(auto_score: engine.calculate_score(commit))
          ScoreCommitJob.perform_later(commit.id.to_s)
        rescue StandardError => e
          Sidekiq.logger.info "Commit: #{commit.id}, Error: #{e}"
        end
      end
    end

    return true
  end

  def set_files_commit_count
    git.ls_files.each do |file, options|
      code_file = self.code_files.find_or_initialize_by(name: file)
      code_file.commits_count = git.file_commits_count(file)
      code_file.save
    end
  end

  def score_activities(round = nil)
    _activities = round ? activities.where(round: round) : activities
    _activities.each(&:calculate_score_and_set)
  end

  def create_popular_repo
    gh_repo = self.info.source
    repo = Repository.where(gh_id: gh_repo.id).first
    return repo if repo

    repo = Repository.build_from_gh_info(gh_repo)
    repo.type = 'popular'
    repo.save
    Repository.create_repo_owner_account(gh_repo)

    return repo
  end
end
