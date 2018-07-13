class CommitReward
  def calculate
    set_score
    set_reward_for_commit
    create_transaction
  end

  private

  def set_score
    day_commits.each do |commit|
      score = rand(10)
      commit.set(score: score)
      update_user_badge(commit)
    end
  end

  def set_reward_for_commit
    day_commits.each do |commit|
      commit.update(reward: rand(10))
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
    Date.yesterday.beginning_of_day..Date.yesterday.end_of_day
  end

  def day_commits 
    Commit.where(commit_date: current_date_range)
  end

  def update_user_badge(commit)
    user = commit.user
    language = commit.repository.language
    user.badges[language] = 0 if user.badges[language].nil?
    user.badges[language] += commit.score
    user.save
  end
end
