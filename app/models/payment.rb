class Payment
  include Mongoid::Document

  field :subscription_plan, type: String
  field :amount, type: Integer
  field :date, type: DateTime

  belongs_to :sponsorer_detail

  validates :subscription_plan, :amount, :date, presence: true
  validates :amount, numericality: { only_integer: true, greater_than: 0 }
end
