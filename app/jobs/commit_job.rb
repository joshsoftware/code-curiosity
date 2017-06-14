class CommitJob < ActiveJob::Base
  include ActiveJobRetriesCount
  queue_as :git

  def fetch_commits(repo, user, round, duration)
    begin
      CommitsFetcher.new(repo, user, round).fetch(duration.to_sym)
    rescue Github::Error::NotFound
      # repository moved or deleted means we no longer care about this repos.
      repo.destroy
    rescue Github::Error::UnavailableForLegalReasons
      # repository permission invoked.
      repo.destroy
    rescue Github::Error::Unauthorized
      # Auth token issue or Access has been denied OR Rate limit hit.

      # Reset the auth_token, so that it gets refereshed the next time
      # user logs in.
      user.auth_token = nil
      user.save

      # Refresh the gh_client because it's using a stale auth_token. 
      user.refresh_gh_client
      retry_job wait: 5.minutes if @retries_count < MAX_RETRY_COUNT
    rescue Github::Error::Forbidden
      # Probably hit the Rate-limit, use another token
      user.refresh_gh_client
      retry_job wait: 5.minutes if @retries_count < MAX_RETRY_COUNT
    end
  end

  def perform(user, duration, repo = nil, round = nil)
    round = Round.opened unless round

    duration = 'all' if user.created_at > (Time.now - 24.hours)
    user.set(last_gh_data_sync_at: Time.now)

    if repo
      fetch_commits(repo, user, round, duration)
    else
      user.repositories.each do |repo|
        CommitJob.perform_later(user, duration, repo)
      end
    end
  end
end
