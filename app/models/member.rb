class Member
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :username, type: String
  
  has_and_belongs_to_many :teams
  has_many :commits, dependent: :destroy
  has_many :activities, dependent: :destroy

  validates :username, presence: true
  validates :username, uniqueness: true

  scope :team_members, -> { where(:team_id.ne => nil) }
end
