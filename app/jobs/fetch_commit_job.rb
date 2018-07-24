class FetchCommitJob < ActiveJob::Base
  include Sidekiq::Status::Worker
  include ActiveJobRetriesCount
  queue_as :git

  def perform(repo_owner: , repo_name: , branch_name: , **options)
    from_date = options[:from_date].presence || Date.yesterday.beginning_of_day
    to_date = options[:to_date].presence || Date.yesterday.end_of_day

    Sidekiq.logger.info "************************ Commit Job Logger Info **************************"
    Sidekiq.logger.info "Fetching commits of repository: #{repo_name} and owner: #{repo_owner} on the  branch: #{branch_name}"
    Sidekiq.logger.info "from: #{from_date} to: #{to_date}"

    begin
      GitFetcher.new(
               repo_owner: repo_owner,
               repo_name: repo_name,
               branch_name: branch_name,
               from_date: from_date,
               to_date: to_date
              ).fetch_and_store_commits
    rescue Github::Error::NotFound
      # repository moved or deleted means we no longer care about this repos.
      Sidekiq.logger.info "Raised Github::Error::NotFound Exception"
      repo = Repository.find_by(name: repo_name)
      repo.destroy
    rescue Github::Error::UnavailableForLegalReasons
      # repository permission invoked.
      Sidekiq.logger.info "Raised Github::Error::UnavailableForLegalReasons Exception"
      repo = Repository.find_by(name: repo_name)
      repo.destroy
    rescue Github::Error::Unauthorized
      Sidekiq.logger.info "Raised Github::Error::Unauthorized Exception"
      GitApp.update_token
      retry_job wait: 5.minutes if @retries_count < MAX_RETRY_COUNT
    rescue Github::Error::Forbidden
      Sidekiq.logger.info "Raised Github::Error::Forbidden Exception"
      GitApp.update_token
      retry_job wait: 5.minutes if @retries_count < MAX_RETRY_COUNT
    rescue Mongo::Error::SocketError
      retry_job wait: 5.minutes if @retries_count < MAX_RETRY_COUNT
    end
  end
end
