class Round
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :name, type: String
  field :from_date, type: DateTime
  field :end_date, type: DateTime
  field :status, type: String, default: ROUND_CONFIG['states']['inactive']

  validates :name, :from_date, presence: true
  validate :validate_end_date

  has_many :commits
  has_many :activities
  has_many :subscriptions

  def validate_end_date
    errors.add(:end_date, "should be greater than start date.") if  self.end_date and self.end_date.to_i <= self.from_date.to_i
  end

  def open?
    status ==  ROUND_CONFIG['states']['open']
  end

  def graph_data(type)
    title = "Code Curiosity Stats for #{self.name}"
    users = User.contestants
    ### COMMENTING THIS AS GRAPH DOES NOT LOOK GOOD ####
    #data = {
    #  activities: {name: "Activities", data: Array.new(users.count, 0)},
    #  commits: {name: "Commits", data: Array.new(users.count, 0)},
    #  scores: {name: "Scores", data: Array.new(users.count, 0)}
    #}

    #users.each_with_index do |user, i|
    #  data[:activities][:data][i]  = get_activities(user)
    #  data[:scores][:data][i]      = get_score(user)
    #  data[:commits][:data][i]     = get_commits(user)
    #end

    data = Array.new(users.count, 0)
    users.each_with_index do |user, i|
      data[i] = case type
                when 'activity'
                  get_activities(user)
                when 'score'
                  get_score(user)
                else
                  get_commits(user)
                end
    end
    return { title: title, users: users.pluck(:name), graph_series: [{name: type.titleize, data: data}]}
  end

  def get_activities(user)
    user.activities.for_round(self.id).count
  end

  def get_commits(user)
    user.commits.for_round(self.id).count
  end

  def get_score(user)
    commit_scores = user.commits.for_round(self.id).map(&:scores).reject(&:empty?).collect{|c| c.sum(:rank).to_f / c.size.to_f }.sum.round(2)
    activity_scores = user.activities.for_round(self.id).map(&:scores).reject(&:empty?).collect{|c| c.sum(:rank).to_f / c.size.to_f }.sum.round(2)
    commit_scores + activity_scores
  end

  def round_close
    end_date = from_date.end_of_month
    self.set({name: self.update_round_name(end_date), end_date: end_date.end_of_day, status: 'close'})

    next_start_date = end_date + 1.second

    new_round = Round.new({
      name: next_start_date.strftime("%b %Y"),
      from_date: next_start_date,
      status:  ROUND_CONFIG['states']['open']
    })
    new_round.save
  end

  def update_round_name(end_date)
    "Round-#{Round.count} (#{self.from_date.strftime("%d %b %Y")} - #{end_date.strftime("%d %b %Y")})"
  end
end
