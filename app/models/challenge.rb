class Challenge
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  STATUS_OPTIONS = ['success', 'crossed threshold', 'failure', 'ongoing']

  field :duration, type: Integer
  field :active_from, type: Time
  field :active_till, type: Time
  field :status, type: String, default: ""
  field :next_level, type: Integer

  validates :duration, :active_from, :active_till, :status, presence: true
  validates :status, inclusion: STATUS_OPTIONS
  
  belongs_to :user
  belongs_to :challenge_type
  belongs_to :level
end
