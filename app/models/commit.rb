class Commit
  include Mongoid::Document
  include Mongoid::Timestamps

  COMMIT_TYPE = {score: "Scores", commit: "Commits", activity: "Activities"}

  field :message, type: String
  field :commit_date, type: DateTime
  field :html_url, type: String

  belongs_to :user
  belongs_to :repository
  belongs_to :round

  has_many :scores, as: :scorable, dependent: :destroy

  validates :message, uniqueness: {:scope => :commit_date}
  
  scope :for_round, -> (round_id) { where(:round_id => round_id) }

  def avg_score
    self.scores.avg(:rank)
  end

  def list_scores
    self.scores.inject(""){|r, s| r += "#{s.user.name}: #{s.rank}<br/>"}
  end
end
