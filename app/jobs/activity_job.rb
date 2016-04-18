class ActivityJob < ActiveJob::Base
  queue_as :git

  def perform(user, round = nil)
    round = Round.opened unless round

    if round
      ActivitiesFetcher.new(user, round).fetch
    end
  end
end
