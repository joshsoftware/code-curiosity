class Payment
  include Mongoid::Document

  field :subscription_plan, type: String
  field :amount, type: Integer
  field :date, type: DateTime

end
