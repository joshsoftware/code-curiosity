class Budget
  include Mongoid::Document
  include Mongoid::Timestamps

  field :start_date,     type: Date
  field :end_date,       type: Date
  field :day_amount,     type: Float
  field :amount,         type: Float
  field :is_all_repos,   type: Boolean, default: false
  field :is_deactivated, type: Boolean, default: false

  belongs_to :sponsor
  has_and_belongs_to_many :repositories

  validates :start_date, :end_date, :amount, presence: true

  scope :activated, -> { where(is_deactivated: false) }

  after_save do |sponsor|
    sponsor.set(day_amount: calculate_day_amount)
  end

  private

  def calculate_day_amount
    number_of_days = (end_date - start_date).to_i + 1
    amount/number_of_days
  end
end
