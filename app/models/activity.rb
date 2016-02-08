class Activity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description,   type: String
  field :event_type,    type: String
  field :repo,          type: String
  field :ref_url,       type: String
  field :commented_on,  type: Time

  belongs_to :user
  belongs_to :round

  has_many :scores, as: :scorable, dependent: :destroy

  validates :description, uniqueness: {:scope => :commented_on}

  scope :for_round, -> (round_id) { where(:round_id => round_id) }

  after_create do |a|
    a.user.inc(activities_count: 1)
  end

  def avg_score
    self.scores.avg(:rank)
  end

  def list_scores
    self.scores.inject(""){|r, s| r += "#{s.user.name}: #{s.rank}<br/>"}
  end
end
