class Level
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :number, type: Integer
  field :max_points, type: Integer
  field :threshold_points, type: Integer
  field :max_reward, type: Float
  field :threshold_reward, type: Float

  validates :number, :max_points, :threshold_points, :max_reward, :threshold_reward,
  	presence: :true

  has_many :challenges
  has_and_belongs_to_many :challenge_types
end
