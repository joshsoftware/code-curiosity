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
        UserReposJob.perform_later(user.id.to_s)
        user.repositories.each do |repo| 
          CommitJob.perform_later(user.id.to_s, type, repo.id.to_s, round.id.to_s)
        end
        ActivityJob.perform_later(user.id.to_s, type, round.id.to_s)
      end
    end
  end

  desc "Restore Repository and associated user"
  task restore_repositories: :environment do
    # get all deleted repositories
    Repository.deleted.each do |deleted_repo|
      # get the users for the deleted repository and recreate the relationship
      deleted_repo.users.each do |user|
        user.repositories << deleted_repo
      end
      # restore the repository.
      deleted_repo.restore
    end
  end

  desc "Update user redeemed points transactions"
  task update_user_redemed_points: :environment do
    User.contestants.each do |user|
      user.transactions.where(transaction_type: 'redeem_points').each do |transaction|
        total_points = 0
        points = transaction.points.abs
        total_points = user.transactions.where(:created_at.lt => transaction.created_at).sum(:points)
        royalty_points = user.royalty_bonus_transaction ? user.royalty_bonus_transaction.points : 0

        redeemed_royalty_points = points + royalty_points - total_points

        redeemed_royalty_points = 0 if redeemed_royalty_points <= 0

        redeemed_royalty_points = points if redeemed_royalty_points > points

        round_points = points - redeemed_royalty_points

        transaction.create_redemption_transaction({
          round_points: round_points,
          royalty_points: redeemed_royalty_points,
          round_name: transaction.created_at.strftime("%b %Y")
          })
      end
    end
  end
end
