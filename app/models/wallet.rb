class Wallet
  include Mongoid::Document
  field :points, type: Integer
  field :type, type: String
end
