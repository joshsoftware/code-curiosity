class ChallengeType
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :name, type: String, default: ""
  field :max_level, type: Integer
  field :max_amount, type: Float
  field :start_date, type: Time
  field :end_date, type: Time
  field :max_duration, type: Array

  validates :name, :max_level, :max_amount, :start_date, :end_date,
  	:max_duration, presence: true

  has_many :challenges
  has_and_belongs_to_many :levels
end
