class Snapshot
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :from_date, type: DateTime
  field :end_date, type: DateTime
  field :graphdata, type: Hash

  validates :from_date, :end_date, presence: true

  def self.get_graphdata(category, round)
   data = []
   return data unless round
   snapshot = Snapshot.where(:from_date => round).first
   if snapshot
     snapshot.graphdata.each do |member|
       # []
     end
   end
   data
  end

  def round_period
    ["#{self.from_date.strftime("%d %b %Y")} - #{self.end_date.strftime("%d %b %Y")}", self.from_date]
  end
end
