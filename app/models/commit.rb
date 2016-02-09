class Commit
  include Mongoid::Document
  include Mongoid::Timestamps
  include ScoreHelper

  COMMIT_TYPE = {score: "Scores", commit: "Commits", activity: "Activities"}

  field :message, type: String
  field :commit_date, type: DateTime
  field :html_url, type: String
  field :comments_count, type: Integer, default: 0

  belongs_to :user
  belongs_to :repository
  belongs_to :round
  has_many :comments
  embeds_many :scores, as: :scorable

  validates :message, uniqueness: {:scope => :commit_date}

  scope :for_round, -> (round_id) { where(:round_id => round_id) }

  index({ user_id: 1, round_id: 1 })
  index({ repository_id: 1 })
  index({ created_at: -1 })

  after_create do |c|
    c.user.inc(commits_count: 1)
  end

end
