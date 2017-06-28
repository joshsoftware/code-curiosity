class ScoringJob < ActiveJob::Base
  queue_as :git

  def perform(repository, round, type)
    Sidekiq.logger.info "******************* Logger Info for Scoring Job **************************"
    Sidekiq.logger.info "Scoring for Repository: #{repository.name}, User: #{repository.owner}, Current Round: from #{round.from_date}, Type: #{type}"
    if type == 'commits'
      repository.score_commits(round)
    elsif type == 'activities'
      repository.score_activities(round)
    end
  end
end
