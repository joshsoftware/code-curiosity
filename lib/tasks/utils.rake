namespace :utils do
  desc "Update user points"
  task update_user_total_points: :environment do
    User.contestants.each do |user|
      points = user.transactions.inject(0){|r, t| r += t.points; r}
      user.set(points: points)
    end
  end

  desc 'remove dublicate repos'
  task remove_dublicate_repos: :environment do
    repo_groups = {} 

    Repository.all.each do |r|
      repo_groups[r.gh_id] ||= []
      repo_groups[r.gh_id] << r
    end

    repo_groups.select!{|k,v| v.length > 1}

    puts repo_groups

    dublicate_repos_with_activies  = []

    repo_groups.each do |k, v| 
      repos = v.sort_by &:created_at

      activities = []

      repos[1..-1].collect do |r| 
        count = r.commits.count + r.activities.count

        if count > 0
          dublicate_repos_with_activies << r
        end

        #r.commits.destroy_all
        #r.activities.destroy_all
        r.destroy 
      end
    end

    puts dublicate_repos_with_activies.collect &:id
  end

  desc "Update comment"
  task update_activities_event_action: :environment do
    Activity.where(event_type: :comment, event_action: nil).update_all(event_action: :created)

    begin
      # get most recent users
      recent_users = User.where(:auth_token.ne => nil).order(updated_at: :desc).to_a[0..10]
      user_ids = Activity.where(event_type: :issue, event_action: nil).pluck(:user_id)
      # find users whose activity's event_actions are nil
      users = User.where(:id.in => user_ids)
      users.each do |user|
        begin
          recent_user = recent_users.sample

          #retrieve all activities performed by user
          activities = recent_user.gh_client.activity.events.performed(user.github_handle, auto_pagination: true, per_page: 200)
          activities = activities.select{|i| ActivitiesFetcher::TRACKING_EVENTS.key?(i.type)}
          activities.each do |a|
            act = user.activities.where(event_type: :issue, gh_id: a.id, event_action: nil).first
            act.set(event_action: a.payload['action']) if act
            next if user.activities.where(event_action: nil).count == 0
          end
        rescue Github::Error::NotFound
          # user not found
          next
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          # user auth token is invalid
          retry
        rescue
          retry
        end
      end
    rescue Mongo::Error::OperationFailure
      retry
    end
  end

  desc "Hackathon Sync"
  task :hackathon, [:group] => :environment do |t, args|
    group = Group.where(name: args[:group]).first
    if group # Ignore if incorrect name
      type = "all"
      round = Round.opened
      group.members.each do |user|
        UserReposJob.perform_later(user)
        user.repositories.each do |repo| 
          CommitJob.perform_later(user, type, repo, round)
        end
        ActivityJob.perform_later(user, type, round)
      end
    end
  end

end
