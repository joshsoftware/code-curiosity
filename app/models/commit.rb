class Commit
  include Mongoid::Document
  include Mongoid::Timestamps

  COMMIT_TYPE = {score: "Team scores", commit: "Team commits", activity: "Team activities"}

  field :message, type: String
  field :commit_date, type: DateTime
  field :html_url, type: String

  belongs_to :member
  belongs_to :repository
  belongs_to :team
  belongs_to :round

  has_many :scores, as: :scorable, dependent: :destroy

  validates :message, uniqueness: {:scope => :commit_date}
  
  scope :for_round, -> (round_id) { where(:round_id => round_id) }
end
