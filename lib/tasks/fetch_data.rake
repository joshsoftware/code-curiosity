namespace :fetch_data do
  desc "Sync repositories for every user"
  task :sync_repos => :environment do |t, args|
    per_batch = 1000
    # dont fetch repos of blocked users
    users = User.contestants.allowed

    0.step(users.count, per_batch) do |offset|
      users.limit(per_batch).skip(offset).each do |user|
        UserReposJob.perform_later(user.id.to_s)
      end
    end
  end

  desc "fetch github_user_since for every user"
  task :github_user_since => :environment do |t, args|
    users = User.where(:auth_token.ne => nil).desc(:last_sign_in_at).first

    User.where(auto_created: false, github_user_since: nil).each do |user|
      begin
        github = users.gh_client.users.get user: user.github_handle
        user.set(github_user_since: github.created_at)
      rescue Github::Error::NotFound
        # This user does not exist.. ignore and complete the job.
        {}
      rescue Github::Error::Unauthorized
        # Auth token issue or Access has been denied.
        # Reset the auth_token, so that it gets refereshed the next time
        # user logs in.
        users.auth_token = nil
        users.save

        users.refresh_gh_client
        retry

      rescue Github::Error::Forbidden
        users.refresh_gh_client
        retry
      end
    end
  end
end
