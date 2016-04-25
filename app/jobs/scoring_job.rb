class ScoringJob < ActiveJob::Base
  queue_as :git

  def perform(repository, round, type)
    if type == 'commits'
      repository.score_commits(round)
    elsif type == 'activities'
      repository.score_activities(round)
    end
  end
end
