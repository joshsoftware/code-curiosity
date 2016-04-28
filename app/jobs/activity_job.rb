class ActivityJob < ActiveJob::Base
  queue_as :git

  def perform(user, duration, round = nil)
    round = Round.opened unless round

    if round
      duration = 'all' if user.created_at > round.from_date.beginning_of_day
      ActivitiesFetcher.new(user, round).fetch(duration.to_sym)
    end
  end
end
