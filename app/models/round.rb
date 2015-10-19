class Round
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String
  field :from_date, type: DateTime
  field :end_date, type: DateTime
  field :graphdata, type: Hash
  field :status, type: String, default: "open" 

  validates :from_date, presence: true

  def self.graph_data(id, type)
   round = Round.find(id)
   title = round.present? ? "Code Curiosity Stats for #{round.name}" : "No Data"
   graph_series = []
   teams = Team.all.order(name: :asc)
   graph_series = round.status == "open" ? open_round(round, graph_series, teams, type) : close_round(round, graph_series, teams, type)
   return { title: title, teams: teams.pluck(:name), graph_series: graph_series, yaxis_title: Commit::COMMIT_TYPE[type.to_sym]}
  end
  
  def self.open_round(round, graph_series, teams, type)
   blank_row = [-1]*Team.count
   teams.each_with_index do |team, i|
     team.members.each do |member|
       data = blank_row.clone

       if type == "activity"
         data[i] = member.activities.where(:commented_on.gte => round.from_date).count
       elsif type == "score"
         commit_scores = member.commits.map(&:scores).collect{|c| c.map(&:rank)}.collect{ |c| c.sum}.sum
         activity_scores = member.activities.map(&:scores).collect{|c| c.map(&:rank)}.collect{ |c| c.sum}.sum
         data[i] = commit_scores + activity_scores
       else
         data[i] = member.commits.where(:commit_date.gte => round.from_date).count
       end
       graph_series << { name: member.username, data: data }
     end
   end
   graph_series
  end

  def self.close_round(round, graph_series, teams, type)
    graph_series
  end
end
