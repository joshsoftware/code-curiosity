module ScoresHelper
  def score_color(scorable)
    case scorable.scores.count
    when 0
      'bs-callout bs-callout-danger'
    when 1 
      'bs-callout bs-callout-warning'
    when 2 
      'bs-callout bs-callout-warning'
    else
      'bs-callout bs-callout-success'
    end
  end

  def status_color(user)
    # TODO: optimize this using mongoDB aggregation query to get the number
    # of commits that have less than 3 scores.
    # Kept a case statement incase we need more color codes later on
    counter = user.commits.includes(:scores).select { |c| c.scores.count < 3 }.count
    if counter == 0
      counter = user.activities.includes(:scores).select { |c| c.scores.count < 3 }.count
    end
    case counter
    when 0
      'bs-callout bs-callout-success'
    else
      'bs-callout bs-callout-warning'
    end
  end
end
