class Activity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description,     type: String
  field :event_type,      type: String
  field :repo,            type: String
  field :ref_url,         type: String
  field :commented_on,    type: Time
  field :comments_count,  type: Integer, default: 0
  field :gh_id,           type: String
  field :auto_score,      type: Integer

  belongs_to :user
  belongs_to :round
  belongs_to :repository
  has_many :comments, as: :commentable
  embeds_many :scores, as: :scorable

  validates :description, uniqueness: {:scope => :commented_on}

  scope :for_round, -> (round_id) { where(:round_id => round_id) }

  index({ created_at: -1 })
  index({ event_type: 1, gh_id: 1 })

  after_create do |a|
    a.user.inc(activities_count: 1)
  end

  def calculate_score_and_set
    words = description.to_s.split(/\W+/)
    self.auto_score = 0
    self.auto_score = 2 if words.length > 40
    self.auto_score = 1 if words.length > 25
    self.save
  end
end
