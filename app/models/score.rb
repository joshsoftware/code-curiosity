class Score
  include Mongoid::Document

  field :rank, type: Integer
  field :comment, type: String

  belongs_to :scorable, polymorphic: true
  belongs_to :user

  validates :user, presence: true

  def self.my_score(user)
    where(user: user).first.try(:rank)
  end
end
