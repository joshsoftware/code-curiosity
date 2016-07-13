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

  desc "Score not scored commits and activities"
  task scoring_not_scored_commits_and_activities: :environment do
    commits_repo_ids = Commit.where(auto_score: nil).distinct(:repository_id)

    Repository.find(commits_repo_ids).each do |repo|
      ScoringJob.perform_later(repo, nil, 'commits')
    end

    activities_repo_ids = Activity.where(auto_score: nil).distinct(:repository_id)

    Repository.find(activities_repo_ids).each do |repo|
      ScoringJob.perform_later(repo, nil, 'activities')
    end
  end
end
