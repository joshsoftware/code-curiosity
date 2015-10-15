class Member
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :username, type: String
  
  belongs_to :team
  has_many :commits

  validates :username, presence: true
  validates :username, uniqueness: true

  scope :team_members, -> { where(:team_id.ne => nil) }
end
