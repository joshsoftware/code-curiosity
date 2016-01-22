class Transaction
  include Mongoid::Document

  field :type, type: String
  field :points , type: Integer , default:0
  
  belongs_to :user
  validates :type, :points , presence: true
  

end
