class CommitJob < ActiveJob::Base
  include ActiveJobRetriesCount
  queue_as :git

  def fetch_commits(repo, user, round, duration)
    Sidekiq.logger.info "************************ Commit Job Logger Info **************************"
    Sidekiq.logger.info "Fetching commits of repository: #{repo.name} and owner: #{repo.owner}, User: #{user.github_handle}, Current Round: from #{round.from_date}, Duration: #{duration}"

    begin
      CommitsFetcher.new(repo, user, round).fetch(duration.to_sym)
    rescue Github::Error::NotFound
      # repository moved or deleted means we no longer care about this repos.
      Sidekiq.logger.info "Raised Github::Error::NotFound Exception"
      repo.destroy
    rescue Github::Error::UnavailableForLegalReasons
      # repository permission invoked.
      Sidekiq.logger.info "Raised Github::Error::UnavailableForLegalReasons Exception"
      repo.destroy
    rescue Github::Error::Unauthorized
      # Auth token issue or Access has been denied OR Rate limit hit.

      # Reset the auth_token, so that it gets refereshed the next time
      # user logs in.
      Sidekiq.logger.info "Raised Github::Error::Unauthorized Exception"
      user.auth_token = nil
      user.save

      # Refresh the gh_client because it's using a stale auth_token. 
      user.refresh_gh_client
      retry_job wait: 5.minutes if @retries_count < MAX_RETRY_COUNT
    rescue Github::Error::Forbidden
      # Probably hit the Rate-limit, use another token
      Sidekiq.logger.info "Raised Github::Error::Forbidden Exception"
      user.refresh_gh_client
      retry_job wait: 5.minutes if @retries_count < MAX_RETRY_COUNT
    rescue Mongo::Error::SocketError
      retry_job wait: 5.minutes if @retries_count < MAX_RETRY_COUNT
    end
  end

  def perform(user_id, duration, repo_id = nil, round_id = nil)
    if round_id
      round = Round.find(round_id)
    else
      round = Round.opened
    end
    
    user = User.find(user_id)
    duration = 'all' if user.created_at > (Time.now - 24.hours)
    user.set(last_gh_data_sync_at: Time.now)

    if repo_id
      repo = Repository.find(repo_id)
      fetch_commits(repo, user, round, duration)
    else
      user.repositories.required.each do |repo|
        CommitJob.perform_later(user.id.to_s, duration, repo.id.to_s)
      end
    end
  end
end
