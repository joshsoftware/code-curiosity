class ActivityJob < ActiveJob::Base
  include Sidekiq::Status::Worker
  include ActiveJobRetriesCount
  queue_as :git

  def perform(user_id, duration, round_id = nil)
    if round_id
      round = Round.find(round_id)
    else
      round = Round.opened
    end

    user = User.find(user_id)

    Sidekiq.logger.info "******************* Activity Job Logger Info ***********************"

    if round
      duration = 'all' if user.created_at > (Time.now - 24.hours)
      begin
        Sidekiq.logger.info "Fetching activities of user #{user.github_handle}, Current Round: from #{round.from_date}, Duration: #{duration}"
        ActivitiesFetcher.new(user, round).fetch(duration.to_sym)
      rescue Github::Error::NotFound
        # This user does not exist.. ignore and complete the job.
        Sidekiq.logger.info "Raised Github::Error::Notfound Exception"
        {}
      rescue Github::Error::Unauthorized
        # Auth token issue or Access has been denied.

        # Reset the auth_token, so that it gets refereshed the next time
        # user logs in.
        Sidekiq.logger.info "Raised Github::Error::Unauthorized Exception"

        user.auth_token = nil
        user.save

        # Refresh the gh_client because it's using a stale auth_token.
        # Here we use the App auth_token instead of user auth_token
        user.refresh_gh_client
        retry_job wait: 5.minutes if retries_count < MAX_RETRY_COUNT
      rescue Github::Error::Forbidden
        # Probably hit the Rate-limit, use another token
        Sidekiq.logger.info "Raised Github::Error::Forbidden Exception"
        user.refresh_gh_client
        retry_job wait: 5.minutes if retries_count < MAX_RETRY_COUNT
      end
    end
  end
end
