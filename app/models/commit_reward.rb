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
      score = 0
      score = CommitScore.new(commit, commit.repository).calculate if commit.repository
      commit.set(score: score)
      update_user_badge(commit)
    end
  end

  def set_reward_for_commit(repo_budget)
    day_commits.each do |commit|
      commit.update(reward: 0)
      if commit.repository
        id = commit.repository.id.to_s
        reward = (commit.score * repo_budget[id][:factor]).round(1)
        commit.update(reward: reward)
      end
    end
  end

  def create_transaction
    day_commits.group_by(&:user_id).map do |user_id, commits|
      user = User.find(user_id)
      user.create_transaction(
        type: 'credit',
        points: commits.sum{|c| c.reward.to_f },
        description: "Daily reward: #{Date.today - 1}",
        transaction_type: 'daily reward'
      )
      user.points = user.points.nil? ? 0 : user.points
      user.points += commits.sum(&:score)
      user.save
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
      user.badges[language] += commit.score if !user.badges[language].nil?
      user.save
    end
  end
end
