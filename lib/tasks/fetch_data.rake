namespace :fetch_data do
  desc "Fetch code-curiosity github repositories commits and activities periodically."
  task :commits_and_activities, [:type] => :environment do |t, args|
    type = args[:type] || 'daily'
    puts "Running for #{type}"

    per_batch = 1000
    users = User.where(auto_created: false)

    0.step(users.count, per_batch) do |offset|
      users.limit(per_batch).skip(offset).each do |user|
        #CommitJob.perform_later(user, type)

        user.repositories.required.each do |repo| 
          CommitJob.perform_later(user.id.to_s, type, repo.id.to_s)
        end

        ActivityJob.perform_later(user.id.to_s, type)
      end
    end
  end

  desc "Fetch data for all rounds"
  task :all_rounds => :environment do |t, args|
    type = 'all'
    users = User.where(auto_created: false)
    
    Subscription.all.each do |subscription|
      round = Round.find(subscription.round_id)
      user  = User.find(subscription.user_id)
      
      user.repositories.required.each do |repo| 
        CommitJob.perform_later(user.id.to_s, type, repo.id.to_s, round.id.to_s)
      end
      ActivityJob.perform_later(user.id.to_s, type, round.id.to_s)
    end
  end

  desc "Sync repositories for every user"
  task :sync_repos => :environment do |t, args|
    per_batch = 1000
    users = User.where(auto_created: false)

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
