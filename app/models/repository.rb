class Repository
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,        type: String
  field :description, type: String
  field :watchers,    type: Integer
  field :owner,       type: String
  field :source_url,  type: String
  field :gh_id,       type: Integer

  has_many :commits
  has_many :activities
  has_and_belongs_to_many :users
  has_and_belongs_to_many :judges, class_name: 'User', inverse_of: 'judges_repositories'

  validates :source_url, uniqueness: true, presence: true, format: { with: /\A(https|http):\/\/github.com\/[\.\w-]+\/[\.\w-]+\z/ }
  validates :name, presence: true, uniqueness: {scope: :owner}

  before_validation :parse_owner_info

  index({source_url: 1})

  GITHUB_URL = 'https://github.com'

  def self.add_new(params, user)
    owner, name = params[:source_url].split('/')

    info = GithubClient.repo(owner, name)
    return Repository.new unless info

    source_url = GITHUB_URL + '/' + params[:source_url].to_s.sub(/\.git$/, '')
    repo = Repository.find_or_create_by(source_url: source_url)

    if repo.valid?
      repo.users << user unless repo.users.include?(user)
      repo.set(description: info.description, watchers: info.watchers, gh_id: info.id)
    end

    repo
  end

  def parse_owner_info
    self.source_url = source_url.to_s.sub(/\.git$/, '')
    names = self.source_url.sub(/(https|http):\/\/github.com\//, '').split("/")
    self.owner, self.name = names
  end

  def repository_uri
    self.source_url.to_s.sub(/(https|http):\/\/github.com\//, '')
  end

  def judges_name
    judges.map(&:github_handle).join(",")
  end

end
