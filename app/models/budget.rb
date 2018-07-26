class Budget
  include Mongoid::Document
  include Mongoid::Timestamps

  field :start_date,    type: Date
  field :end_date,      type: Date
  field :day_amount,    type: Float
  field :amount,        type: Float
  field :is_all_repos,	type: Boolean, default: false

  has_and_belongs_to_many :repositories
  belongs_to :sponsor

  validates :start_date, :end_date, :amount, presence: true

  after_save do |sponsor|
    sponsor.set(day_amount: calculate_day_amount)
  end

  private

  def calculate_day_amount
    number_of_days = (end_date - start_date).to_i + 1
    amount/number_of_days
  end
end
