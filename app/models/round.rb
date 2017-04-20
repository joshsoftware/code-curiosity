class Round
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :name, type: String
  field :from_date, type: DateTime
  field :end_date, type: DateTime
  field :status, type: String, default: ROUND_CONFIG['states']['inactive']

  validates :name, :from_date, presence: true
  validates :status, inclusion: { in: ROUND_CONFIG['states'].keys }
  validates :status, uniqueness: true, if: :active_round?
  validate :validate_end_date

  has_many :commits
  has_many :activities
  has_many :subscriptions

  def validate_end_date
    if self.end_date and self.end_date.to_i <= self.from_date.to_i
      errors.add(:end_date, "should be greater than start date.")
    end
  end

  def self.opened
    Round.where(status: ROUND_CONFIG['states']['open']).first
  end

  def inactive?
    status ==  ROUND_CONFIG['states']['inactive']
  end

  def open?
    status ==  ROUND_CONFIG['states']['open']
  end

  def closed?
    status ==  ROUND_CONFIG['states']['close']
  end

  def round_close
    end_date = from_date.end_of_month
    self.set(end_date: end_date.end_of_day, status: 'close')

    next_start_date = end_date + 1.second

    new_round = Round.new({
      name: next_start_date.strftime("%b %Y"),
      from_date: next_start_date,
      status:  ROUND_CONFIG['states']['open']
    })
    new_round.save
  end

  # Check that the current round is a new_record, is open and no other open round exists
  def active_round?
    if open? and new_record? and Round.opened
      errors.add(:status, 'open round already exists')
    end
  end

end
