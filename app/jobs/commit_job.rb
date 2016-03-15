class CommitJob < ActiveJob::Base
  queue_as :git

  def perform(user = nil, repo = nil, round_id = nil)
    CommitsFetcher.new(repo, user, round_id).fetch
  end
end
