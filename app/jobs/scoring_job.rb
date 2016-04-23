lass ScoringJob < ActiveJob::Base
  queue_as :git

  def perform(repository, round = nil)
    repository.score_commits(round)
  end
end
