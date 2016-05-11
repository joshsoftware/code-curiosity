class Goal
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :name, type: String
  field :points, type: Integer

  validates :name, presence: true
  validates :points, numericality: { only_integer: true, greater_than: 0 }
end
