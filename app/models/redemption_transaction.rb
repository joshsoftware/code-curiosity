class RedemptionTransaction
  include Mongoid::Document

  field :round_points, type: Integer, default: 0
  field :royalty_points, type: Integer, default: 0
  field :goal_bonus_points, type: Integer, default: 0
  field :round_name, type: String 
  
  belongs_to :transaction
end