class Offer
  include Mongoid::Document

  field :name,               type: String, default: ""
  field :email,              type: String, default: ""
  field :active_from,        type: Date
  field :active_till,        type: Date

  validates :email, :name, :active_from, :active_till, presence: true


  def self.is_winner?(user)
    Offer.where(
    	:email => user.email,
    	:active_from.lte => Date.today,
    	:active_till.gte => Date.today
    	).present?
  end
end
