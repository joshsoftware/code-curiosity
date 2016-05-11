class Score
  include Mongoid::Document
  include Mongoid::Timestamps

  field :value, type: Integer, default: 0
  field :comment, type: String

  embedded_in :scorable, polymorphic: true
  belongs_to :user

  validates :user, :value, presence: true
  validates :value, numericality: { only_integer: true, greater_than: -1 }
end
