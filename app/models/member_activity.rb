class MemberActivity
  include Mongoid::Document
  field :description, type: String
  field :event_type,  type: String
  field :repo,        type: String
  field :ref_url,     type: String

  belongs_to :member
  belongs_to :team
end
