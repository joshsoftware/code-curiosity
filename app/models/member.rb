class Member
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :username, type: String
  
  belongs_to :team

  validates :username, presence: true
end
