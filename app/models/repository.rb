class Repository
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  include RepositoryVerification

  field :name,        type: String
  field :description, type: String
  field :stars,       type: Integer, default: 0
  field :watchers,    type: Integer, default: 0
  field :forks,       type: Integer, default: 0
  field :owner,       type: String
  field :source_url,  type: String
  field :gh_id,       type: Integer
  field :languages,   type: Array
  field :ssh_url,     type: String
  field :code_dir,    type: String
  field :ignore_files, type: Array, default: []
  field :type,        type: String

  has_many :commits
  has_many :activities
  has_many :code_files
  has_and_belongs_to_many :users, class_name: 'User', inverse_of: 'repositories'
  has_and_belongs_to_many :judges, class_name: 'User', inverse_of: 'judges_repositories'
  has_many :repositories, class_name: 'Repository', inverse_of: 'popular_repository'
  belongs_to :popular_repository, class_name: 'Repository', inverse_of: 'repositories'

  validates :name, :source_url, :ssh_url, presence: true
  validate :verify_popularity

  index({source_url: 1})

  scope :popular, -> { where(type: 'popular') }

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

  def self.add_new(params, user)
    repo = user.repositories.where(gh_id: params[:gh_id]).first

    if repo
      repo.users << user unless repo.users.include?(user)
      return repo
    end

    gh_repo = GithubClient.repo(params[:owner], params[:name])
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

  def repository_uri
    self.source_url.to_s.sub(/(https|http):\/\/github.com\//, '')
  end

  def judges_name
    judges.map(&:github_handle).join(",")
  end

  def git
    @git ||= Git.open(code_dir)
  end

  def score_commits(round)
    engine = ScoringEngine.new(self)
    git = engine.refresh_repo
    self.set(code_dir: git.dir.path) if git

    round_commits = self.commits.where(round_id: round).map do |commit|
      commit.branch = git.gcommit(commit.sha).branch rescue nil
      commit
    end

    round_commits.group_by(&:branch).each do |branch, commits|
      commits.each do |commit|
        commit.default_score = engine.default_score(commit.info)
        commit.bugspots_score = engine.bugspots_score(commit.info, branch || 'master')
        commit.auto_score = commit.calculate_score
        commit.save
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
end
