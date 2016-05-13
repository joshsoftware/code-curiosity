class Group
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :name, type: String
  field :description, type: String

  has_and_belongs_to_many :users
end
