class CommitJob < ActiveJob::Base
  queue_as :git

  def perform(user, duration, repo = nil, round = nil)
    round = Round.opened unless round

    duration = 'all' if user.created_at > (Time.now - 24.hours)

    if repo
       CommitsFetcher.new(repo, user, round).fetch(duration.to_sym)
    else
      user.repositories.each do |repo|
        CommitsFetcher.new(repo, user, round).fetch(duration.to_sym)
      end
    end
  end
end
