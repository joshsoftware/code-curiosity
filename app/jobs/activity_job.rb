class ActivityJob < ActiveJob::Base
  queue_as :git

  def perform(user = nil, round_id = nil)
    ActivitiesFetcher.new(user, round_id).fetch
  end
end
