# Fetch Github activities for the specified user.
class ActivitiesFetcher
  def initialize(user)
    @user = user
  end

  attr_accessor :user

  def fetch
    begin
      user.gh_client.activity.events.performed(user.github_handle, auto_pagination: true)
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
      retry
    rescue Github::Error::Forbidden
      # Probably hit the Rate-limit, use another token
      user.refresh_gh_client
      retry
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      user.refresh_gh_client
      retry
    end
  end
end
