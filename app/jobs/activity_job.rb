class ActivityJob < ActiveJob::Base
  queue_as :git

  def perform(user, duration, round = nil)
    round = Round.opened unless round

    if round
      duration = 'all' if user.created_at > (Time.now - 24.hours)
      activities = ActivitiesFetcher.new(user).fetch
      ActivitiesProcessor.new(user, round, activities).process(duration.to_sym)
    end
  end
end
