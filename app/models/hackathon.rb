class Hackathon < Subscription
  field :update_interval, type: Integer, default: 15

  belongs_to :group
end
