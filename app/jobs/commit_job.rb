class CommitJob < ActiveJob::Base
  queue_as :git

  def perform(user, repo = nil, round = nil)
    round = Round.opened unless round

    if repo
       CommitsFetcher.new(repo, user, round).fetch
    else
      user.repositories.each do |repo|
        CommitsFetcher.new(repo, user, round).fetch
      end
    end
  end
end
