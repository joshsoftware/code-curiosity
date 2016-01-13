class Repository
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,        type: String
  field :description, type: String
  field :watchers,    type: Integer
  field :owner,       type: String
  field :source_url,     type: String

  has_many :commits
  has_and_belongs_to_many :users
  validates :source_url, uniqueness: true, presence: true
  validates :name, presence: true, uniqueness: {scope: :owner}

  before_validation :parse_owner_info

  def self.add_new(params, user)
    repo  = Repository.find_or_create_by(source_url: params[:source_url])
    repo.users << user unless repo.users.include?(user)
  end

  def parse_owner_info
    names = self.source_url.sub(/(https|http):\/\/github.com\//, '').split("/")
    self.owner, self.name = names
  end
end
