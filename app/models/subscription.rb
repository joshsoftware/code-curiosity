class Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :points, type: Integer, default: 0

  belongs_to :user
  belongs_to :round
  belongs_to :goal
  has_one :transaction

  def commits_count
    self.round.commits.where(user: user).count
  end

  def activities_count
    self.round.activities.where(user: user).count
  end

  def commits_score
    self.round.commits.where(user: user).inject(0){|r, o| r += o.final_score.to_i; r }
  end

  def activities_score
    self.round.activities.where(user: user).inject(0){|r, o| r += o.final_score.to_i; r }
  end

  def update_points
    self.set(points: commits_score + activities_score)

    if points == 0
      self.transaction.destroy if transaction
    else
      create_or_update_transaction
    end
  end

  private

  def create_or_update_transaction
    self.build_transaction unless transaction
    self.transaction.points = self.points
    self.transaction.transaction_type = "Round : #{self.round.from_date.strftime("%b %Y")}"
    self.transaction.type = 'credit'
    self.transaction.user = self.user
    self.transaction.save
  end
end
