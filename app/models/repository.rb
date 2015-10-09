class Repository
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_many :commits
  has_and_belongs_to_many :teams

  def self.fetch_remote_repos
    GITHUB.orgs.teams.list_repos(ORG_TEAM_ID)
  end
end
