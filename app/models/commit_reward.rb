class CommitReward
  attr_accessor :date

  def initialize(date)
    @date = date
  end

  def calculate
    set_score
    repo_budget = RepoBudget.new(@date).calculate
    set_reward_for_commit(repo_budget)
    create_transaction
  end

  private

  def set_score
    day_commits.each do |commit|
      commit.update(score: 0)
      score = CommitScore.new(commit, commit.repository).calculate if commit.repository
      commit.update(score: score) if score
      update_user_badge(commit)
    end
  end

  def set_reward_for_commit(repo_budget)
    day_commits.each do |commit|
      commit.update(reward: 0)
      if commit.score > 0 && commit.repository        
        repo_id = commit.repository_id.to_s
        budgets.each do |budget|
          budget_id = budget.id
          reward = 0
          if commit.reward < commit.score && repo_budget[budget_id]
            reward += (commit.score * repo_budget[budget_id][repo_id][:factor]).round(1)
            reward = 5 if reward > commit.score && reward > 5
            commit.update(reward: reward)
          end
          budget.day_amount -= reward
          budget.day_amount > 5 ? budget.carry_amount = 5 : budget.carry_amount = budget.day_amount
          budget.save
        end
      end
    end
  end

  def create_transaction
    day_commits.group_by(&:user_id).map do |user_id, commits|
      user = User.find(user_id)
      points = commits.sum{|c| c.reward.to_f }
      if points > 0 
        user.create_transaction(
        type: 'credit',
        points: commits.sum{|c| c.reward.to_f },
        description: "Daily reward: #{Date.today - 1}",
        transaction_type: 'daily reward',
        )
        user.points = user.points.nil? ? 0 : user.points
        user.points += commits.sum(&:score)
        user.save
      end
    end
  end

  def current_date_range
    @date.beginning_of_day..@date.end_of_day
  end

  def day_commits
    Commit.where(commit_date: current_date_range)
  end

  def update_user_badge(commit)
    user = commit.user
    if !commit.repository.nil?
      language = commit.repository.language
      if language
        user.badges[language] = 0 if user.badges[language].nil?
        user.badges[language] += commit.score
        user.save
      end
    end
  end

  def budgets
    Budget.activated.where(:start_date.lte => @date, :end_date.gte => @date)
  end
end
