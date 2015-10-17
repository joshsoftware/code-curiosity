class Snapshot
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :from_date, type: DateTime
  field :end_date, type: DateTime
  field :graphdata, type: Hash

  validates :from_date, :end_date, presence: true

  def self.graph_data(round, type)
   snapshot = Snapshot.first#where(:from_date.ge => round).first
   title = snapshot.present? ? "Code Curiosity Stats (#{snapshot.round_period[0]})" : "No Data"
   graph_series = []
   blank_row = [-1]*Team.count

   teams = Team.all.order(name: :asc)
   if snapshot
    teams.each_with_index do |team, i|
     snapshot.graphdata.each do |key, val|
      data = blank_row.clone
      data[i] = val[:commits]
      graph_series << { name: key, data: data }
     end
    end
   end
   return { title: title, teams: teams.pluck(:name), graph_series: graph_series }
  end

  def round_period
    ["#{self.from_date.strftime("%d %b %Y")} - #{self.end_date.strftime("%d %b %Y")}", self.from_date]
  end
end
