class ScoringJob < ActiveJob::Base
  queue_as :git

  def perform(repository, round = nil)
    round = Round.opened unless round
    repository.score_commits(round)
  end
end
