class Score
  include Mongoid::Document

  field :value, type: Integer, default: 0
  field :comment, type: String

  embedded_in :scorable, polymorphic: true
  belongs_to :user

  validates :user, :value, presence: true
end
