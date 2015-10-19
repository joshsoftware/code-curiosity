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
  has_many :teams

  def validate_end_date
    errors.add("End date", "should be greater than start date.") if  self.end_date and self.end_date <= self.from_date
  end

  def self.graph_data(id, type)
    round = Round.find(id)
    title = round.present? ? "Code Curiosity Stats for #{round.name}" : "No Data"
    teams = round.teams.order(name: :asc)
    graph_series = []
    blank_row = [-1]*round.teams.count
    teams.each_with_index do |team, i|
      team.members.each do |member|
        data = blank_row.clone

        if type == "activity"
          data[i] = get_activities(round, member)
        elsif type == "score"
          data[i] = get_score(round, member)
        else
          data[i] = get_commits(round, member)
        end
        graph_series << { name: member.username, data: data }
      end
    end
    return { title: title, teams: teams.pluck(:name), graph_series: graph_series, yaxis_title: Commit::COMMIT_TYPE[type.to_sym]}
  end

  def self.get_activities(round, member)
    member.activities.for_round(round.id).count
  end

  def self.get_commits(round, member)
    member.commits.for_round(round.id).count
  end

  def self.get_score(round, member)
    commit_scores = member.commits.for_round(round.id).map(&:scores).collect{|c| c.map(&:rank)}.collect{ |c| c.sum}.sum
    activity_scores = member.activities.for_round(round.id).map(&:scores).collect{|c| c.map(&:rank)}.collect{ |c| c.sum}.sum
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
