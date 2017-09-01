class ScoreCommitJob < ActiveJob::Base
  include Sidekiq::Status::Worker
  include ActiveJobRetriesCount
  MAX_RETRY_COUNT = 10
  queue_as :score

  def perform(commit_id)
    commit = Commit.find(commit_id)
    engine = ScoringEngine.new(commit.repository)
    begin
      Sidekiq.logger.info "Scoring for commit: #{commit.id}"
      commit.set(auto_score: engine.calculate_score(commit))
    rescue StandardError => e
      Sidekiq.logger.info "Commit: #{commit.id}, Error: #{e}"
      retry_job wait: 5.minutes if retries_count < MAX_RETRY_COUNT
    end
  end
end
