class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type,              type: String
  field :points ,           type: Integer, default: 0
  field :transaction_type,  type: String

  belongs_to :user

  validates :type, :points , presence: true

  def credit?
    type == 'credit'
  end
end
