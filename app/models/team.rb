class Team
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String
  
  has_many :members
  has_many :commits
  has_many :activities
  has_and_belongs_to_many :repos, class_name: "Repository"

  accepts_nested_attributes_for :members, :repos, reject_if: :blank?

  validates :name, presence: true, uniqueness: true

  def self.create_with_members(params)
    team = Team.new(name: params[:name])
    team.members = Member.where(:username.in => params[:members].reject(&:blank?))
    team.save && team
  end

  def active_from
    self.created_at.strftime("%d %b %Y")
  end

  def member_names
    self.members.pluck(:username).join(", ")
  end

  def repo_names
    self.repos.pluck(:name).join(", ")
  end
  
  def add_repos(repos)
    repos.each{ |repo| self.repos.push(Repository.find_by(name: repo)) } 
  end
end
