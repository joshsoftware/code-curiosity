class Payment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :subscription_plan, type: String
  field :amount, type: Integer
  field :date, type: DateTime

  belongs_to :sponsorer_detail, inverse_of: :payments

  validates :subscription_plan, :amount, :date, presence: true
  validates :amount, numericality: { only_integer: true, greater_than: 0 }
end
