class Hackathon < Subscription
  field :update_interval, type: Integer, default: 15

  belongs_to :group

  # Keep the repos information only in the Hackathon object.
  # This will ensure we don't modify existing structure!
  has_and_belongs_to_many :repositories, inverse_of: nil
end
