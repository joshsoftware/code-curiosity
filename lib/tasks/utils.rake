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

  desc "Delete duplicate repositories"
  task remove_dup_repos: :environment do
    repos = Repository.pluck :gh_id
    dup_repos = repos.select{|i| repos.count(i) > 1 }
    dup_repos.each do |dup_repo|
      dups = Repository.where(gh_id: dup_repo).asc(:created_at).to_a
      original_repo = dups[0]
      dups[1..-1].each do |dup|
        # assign the users to the original repo
        dup.users.each{|u| original_repo.users << u unless original_repo.users.include?(u) }

        # assign the judges to the original repo
        dup.judges.each{|a| original_repo.judges << a unless original_repo.judges.include?(a) }

        # assign the commits to the original repo
        dup.commits.each{|c| original_repo.commits << c unless original_repo.commits.include?(c) }

        # assign the activities to the original repo
        dup.activities.each{|a| original_repo.activities << a unless original_repo.activities.include?(a) }

        # assign the code files to the original repo
        dup.code_files.each{|a| original_repo.code_files << a unless original_repo.code_files.include?(a) }

        # assign the repositories to the original repo
        dup.repositories.each{|a| original_repo.repositories << a unless original_repo.repositories.include?(a) }

        # soft delete the repository
        dup.destroy
      end
    end
  end

end
