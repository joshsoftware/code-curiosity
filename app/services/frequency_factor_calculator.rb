class FrequencyFactorCalculator
  def initialize(commit)
    @user = commit.user
    @commit = commit
  end

  attr_reader :user, :commit

  def result
    1 + (weight / threshold)
  end

  private

  def weight
    [weight_sum, 0].max
  end

  def weight_sum
    evaluation_days.collect do |date|
      date.in?(number_of_days_commited) ? 1 : -1
    end.sum.to_f
  end

  def threshold
    SCORING_ENGINE_CONFIG[:frequency_factor_threshold]
  end

  def number_of_days_commited
    @number_of_days_commited ||= user.commits.where(:commit_date.gt => from_date, :commit_date.lt => to_date)
                                .asc(:commit_date)
                                .pluck(:commit_date)
                                .collect(&:to_date)
  end

  def evaluation_days
    (from_date..to_date).collect(&:to_date)
  end

  def from_date
    @from_date ||= commit.commit_date - threshold.days
  end

  def to_date
    @to_date ||= commit.commit_date - 1.day
  end
end
