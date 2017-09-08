class ScoringJob < ActiveJob::Base
  include Sidekiq::Status::Worker
  include ActiveJobRetriesCount

  queue_as :git

  def perform(repository_id, round_id, type)
    repository = Repository.find(repository_id)
    round = Round.find(round_id)

    Sidekiq.logger.info "******************* Logger Info for Scoring Job **************************"
    Sidekiq.logger.info "Scoring for Repository: #{repository.name}, User: #{repository.owner}, Current Round: from #{round.from_date}, Type: #{type}"
    begin
      if type == 'commits'
        repository.score_commits(round)
      elsif type == 'activities'
        repository.score_activities(round)
      end
    rescue Mongo::Error::SocketError
      retry_job wait: 5.minutes if @retries_count < MAX_RETRY_COUNT
    end
  end
end
