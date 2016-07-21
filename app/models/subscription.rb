class Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :points, type: Integer, default: 0

  belongs_to :user
  belongs_to :round
  belongs_to :goal
  has_many :transactions

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
  end

  def credit_points
    return if points == 0

    create_credit_transaction('Round', points)

    if goal && points >= goal.points
      create_credit_transaction('GoalBonus', goal.bonus_points)
    end
  end

  def create_credit_transaction(transaction_type, points)
    transaction = self.transactions.find_or_initialize_by(transaction_type: transaction_type)
    transaction.points = points
    transaction.type = 'credit'
    transaction.description = "#{transaction_type} : #{self.round.from_date.strftime("%b %Y")}"
    transaction.user = self.user
    transaction.save
  end

  def goal_achived?
    #add the blank condition for the auto created users, goal will be blank for those users.
    !goal.blank? and points >= goal.points
  end
end
