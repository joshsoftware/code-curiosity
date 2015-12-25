class Round
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :from_date, type: DateTime
  field :end_date, type: DateTime
  field :status, type: String, default: "open"

  validates :name, :from_date, presence: true
  validate :validate_end_date

  has_many :commits
  has_many :activities

  def validate_end_date
    errors.add("End date", "should be greater than start date.") if  self.end_date and self.end_date <= self.from_date
  end

  def self.graph_data(id, type)
    round = Round.find(id)
    title = round.present? ? "Code Curiosity Stats for #{round.name}" : "No Data"
    users = User.contestants
    graph_series = []
    blank_row = [-1]*users.count
    total = 0

    users.each_with_index do |user, i|
      data = blank_row.clone

      data[i] = case type
                when "activity"
                  get_activities(round, user)
                when "score"
                  get_score(round, user)
                else
                  get_commits(round, user)
                end

      graph_series << { name: user.name, data: data }
      total += data[i]
    end

    if total == 0
      zero_row = [0]*users.count

      graph_series.each do |series|
        series[:data] = zero_row
      end
    end

    return { title: title, users: users.pluck(:name), graph_series: graph_series, yaxis_title: Commit::COMMIT_TYPE[type.to_sym]}
  end

  def self.get_activities(round, user)
    user.activities.for_round(round.id).count
  end

  def self.get_commits(round, user)
    user.commits.for_round(round.id).count
  end

  def self.get_score(round, user)
    commit_scores = user.commits.for_round(round.id).map(&:scores).reject(&:empty?).collect{|c| c.sum(:rank).to_f / c.size.to_f }.sum.round(2)
    activity_scores = user.activities.for_round(round.id).map(&:scores).reject(&:empty?).collect{|c| c.sum(:rank).to_f / c.size.to_f }.sum.round(2)
    commit_scores + activity_scores
  end

  def take_snapshot(end_date)
    return false unless self.from_date < end_date
    self.update_attributes({name: self.update_round_name(end_date), end_date: end_date.end_of_day, status: 'close'})
    new_round = Round.new(name: "Round-#{Round.count + 1} (#{(end_date + 1.day).beginning_of_day.strftime("%d %b %Y")})",
                          from_date: (end_date + 1.day).beginning_of_day)
                          new_round.save
  end

  def update_round_name(end_date)
    "Round-#{Round.count} (#{self.from_date.strftime("%d %b %Y")} - #{end_date.strftime("%d %b %Y")})"
  end
end
