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

  desc "Delete duplicate users"
  task delete_duplicate_users: :environment do
    User.where(uid: /DELETED/i).pluck(:github_handle).uniq.each do |handle|
      # Get the duplicate users in order of creation.
      # Oldest record is the original record and has to be maintained. Delete other records.
      duplicate_users = User.where(github_handle: handle).order_by(created_at: :asc)

      if duplicate_users.count > 1
        # latest account of user was deleted?
        original_user = duplicate_users[0]
        if duplicate_users[-1].deleted?
          original_user.set({deleted_at: Time.now, auto_created: true, active: false, uid: original_user.uid.split('-')[0]})
        else
          original_user.set({uid: original_user.uid.split('-')[0]})
        end

        # assign commits, activities and comments to the original record
        duplicate_users[1..-1].each do |dup_user|
          dup_user.commits.update_all({user_id: original_user.id})
          dup_user.activities.update_all({user_id: original_user.id})
          dup_user.comments.update_all({user_id: original_user.id})
          dup_user.destroy
        end
      else
        original_user = duplicate_users[0]
        original_user.set({deleted_at: Time.now, auto_created: true, active: false, uid: original_user.uid.split('-')[0]})
      end
    end
  end

end
