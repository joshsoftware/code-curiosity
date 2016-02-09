module ScoreHelper
  def avg_score
    if self.scores.any?
      scores.pluck(:value).sum/scores.count
    end
  end

  def list_scores
    self.scores.inject(""){|r, s| r += "#{s.user.name}: #{s.rank}<br/>"}
  end

  def judge_rating(user)
    scores.where(user: user).first.try(:value)
  end
end
