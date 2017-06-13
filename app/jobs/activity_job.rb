class ActivityJob < ActiveJob::Base
  queue_as :git

  def perform(user, duration, round = nil)
    round = Round.opened unless round

    if round
      duration = 'all' if user.created_at > (Time.now - 24.hours)
      begin
        ActivitiesFetcher.new(user, round).fetch(duration.to_sym)
      rescue Github::Error::NotFound
        # This user does not exist.. ignore and complete the job.
        {}
      rescue Github::Error::Unauthorized
        # Auth token issue or Access has been denied. 

        # Reset the auth_token, so that it gets refereshed the next time
        # user logs in.
        user.auth_token = nil
        user.save

        # Refresh the gh_client because it's using a stale auth_token. 
        # Here we use the App auth_token instead of user auth_token
        user.refresh_gh_client
        retry_job wait: 5.minutes
      rescue Github::Error::Forbidden
        # Probably hit the Rate-limit, use another token
        user.refresh_gh_client
        retry_job wait: 5.minutes
      end
    end
  end
end
