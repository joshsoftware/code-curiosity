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
  validates :name, :source_url, uniqueness: true, presence: true

  before_update :parse_owner_info

  def self.add_new(params, user)
    repo  = Repository.find_or_initialize_by(source_url: params[:source_url])

    if repo.new_record?
      parse_owner_info
      repo.save
    end

    repo.users << user unless repo.users.include?(user)
  end

  def parse_owner_info
    names = self.source_url.remove("https://github.com/").split("/")
    self.owner, self.name = names
  end
end
