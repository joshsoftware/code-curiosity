class Activity
  include Mongoid::Document
  include Mongoid::Timestamps
  include JudgeScoringHelper

  # Github event actions for Issue can be any of assigned, unassigned, labeled, unlabeled, opened, edited, closed or reopened.
  # Refer https://developer.github.com/v3/activity/events/types/#issuesevent for more details.
  ISSUE_ACTIONS = %W(assigned unassigned labeled unlabeled opened edited closed reopened)

  # Actions considered for issue scoring.
  ISSUE_CONSIDERED_FOR_SCORING = %W(opened reopened)

  COMMENT_ACTIONS = %W(created edited deleted)

  # Actions considered for comment scoring
  COMMENT_CONSIDERED_FOR_SCORING = %W(created)

  field :description,     type: String
  field :event_type,      type: String
  field :event_action,    type: String
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
  belongs_to :organization

  scope :considered_for_scoring, -> { any_of({event_type: :issue, :event_action.in => ISSUE_CONSIDERED_FOR_SCORING},
                                      {event_type: :comment, :event_action.in => COMMENT_CONSIDERED_FOR_SCORING}) }

  #validates :description, uniqueness: {:scope => :commented_on}
  validates :round, presence: true

  scope :for_round, -> (round_id) { where(:round_id => round_id) }

  index({ commented_on: -1 })
  index({ event_type: 1, gh_id: 1 })

  before_validation :set_round

  after_create do |a|
    a.user.inc(activities_count: 1)
  end

  def calculate_score_and_set
    words = description.to_s.split(/\W+/)
    self.auto_score = case words.length
                      when 0..25  then 0
                      when 26..40 then 1
                      else 2
                      end
    self.save
  end

  def max_rating
    ACTIVITY_RATINGS.last
  end

  private

  def set_round
    # FIXME: This code was added to address a corner case for commits appearing in next round 
    # instead of the last month. However, it will impact scoring and bonus points. Keeping this
    # line commented in case we find a better fix. - Gautam

    self.round = Round.opened
    #self.round = Round.where(:from_date.lte => commented_on, :end_date.gte => commented_on).first unless self.round
  end
end
