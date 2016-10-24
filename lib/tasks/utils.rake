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

  desc "Update event_action for comments and activities"
  task update_activities_event_action: :environment do
    Activity.where(event_type: :comment, event_action: nil).update_all(event_action: :created)
    user_ids = Activity.where(event_type: :issue, event_action: nil).pluck(:user_id).uniq
    sample_user = User.where(auto_created: false, :auth_token.ne => nil).desc(:last_sign_in_at).first

    user_ids.each do |user_id|
      user = User.find user_id
      next if user.nil?
      #retrieve all activities performed by user
      activities = ActivitiesFetcher.new(user).fetch
      activities.select{|i| ActivitiesProcessor::TRACKING_EVENTS.key?(i.type)}.each do |a|
        act = user.activities.where(event_type: :issue, gh_id: a.id, event_action: nil).first
        act.set(event_action: a.payload['action']) if act
        next if user.activities.where(event_action: nil).count == 0
      end
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
