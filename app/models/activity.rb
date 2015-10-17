class Activity
  include Mongoid::Document
  field :description,   type: String
  field :event_type,    type: String
  field :repo,          type: String
  field :ref_url,       type: String
  field :commented_on,  type: Time

  belongs_to :member
  belongs_to :team

  has_many :scores, as: :scorable, dependent: :destroy

end
