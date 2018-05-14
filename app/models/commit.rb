class Commit
  include Mongoid::Document
  include Mongoid::Timestamps
  include JudgeScoringHelper

  COMMIT_TYPE = {score: 'Scores', commit: 'Commits', activity: 'Activities'}

  attr_accessor :branch

  field :message,          type: String
  field :commit_date,      type: DateTime
  field :html_url,         type: String
  field :comments_count,   type: Integer, default: 0
  field :sha,              type: String
  field :auto_score,       type: Integer
  field :default_score,    type: Float, default: 0
  field :bugspots_score,   type: Float, default: 0
  field :score,            type: Float, default: 0
  field :reward,           type: Float, default: 0
  field :frequency_factor, type: Float, default: 1

  belongs_to :user
  belongs_to :repository
  belongs_to :round
  belongs_to :organization
  has_many :comments, as: :commentable
  embeds_many :scores, as: :scorable

  validates :message, uniqueness: {:scope => :commit_date}

  scope :for_round, -> (round_id) { where(:round_id => round_id) }

  index({ user_id: 1, round_id: 1 })
  index({ repository_id: 1 })
  index({ commit_date: -1 })
  index({ sha: 1 })
  index(auto_score: 1)

  before_validation :set_round

  after_create do |c|
    c.user.inc(commits_count: 1)
  end

  #after_create :schedule_scoring_job

  before_create :set_frequency_factor

  def set_frequency_factor
    self.frequency_factor = FrequencyFactorCalculator.new(self).result
  end

  def info
    @info ||= repository ? user.gh_client.repos.commits.get(repository.owner, repository.name, sha, { redirection: true }) : nil
  end

  def max_rating
    COMMIT_RATINGS.last
  end

  private

  def schedule_scoring_job
    Sidekiq.logger.info "Scoring for commit: #{id}, Round: #{round.from_date}"
    ScoreCommitJob.set(wait: Random.new.rand(20).minutes).perform_later(id.to_s)
  rescue StandardError => e
    Sidekiq.logger.info "Commit: #{id}, Error: #{e}"
  end

  def set_round
    # FIXME: This code was added to address a corner case for commits appearing in next round
    # instead of the last month. However, it will impact scoring and bonus points. Keeping this
    # line commented in case we find a better fix. - Gautam

    #self.round = Round.where(:from_date.lte => commit_date, :end_date.gte => commit_date).first unless self.round
    self.round = Round.opened unless self.round
  end

end
