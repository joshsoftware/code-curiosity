class Team
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String

  
  has_many :members
  has_and_belongs_to_many :repositories

  accepts_nested_attributes_for :members, :repositories, reject_if: :blank?

  validates :name, presence: true, uniqueness: true

  def self.create_with_members(params)
    team = Team.new(name: params[:name])
    params[:members].reject(&:blank?).collect{|m| team.members.build(username: m)}
    team.save && team
  end

  def active_from
    self.created_at.strftime("%d %b %Y")
  end
end
