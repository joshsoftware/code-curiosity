class Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :points, type: Integer, default: 0

  belongs_to :user
  belongs_to :round

  def commits_count
    self.round.commits.where(user_id: self.user_id).count
  end

  def activities_count
    self.round.activities.where(user_id: self.user_id).count
  end

end
