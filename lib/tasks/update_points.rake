namespace :update_points do
  desc 'fetch commits and activities and perform scoring'
  task :fetch_and_score, [:user, :round] => :environment do |t, args|
    round = Round.find(args[:round]) if args[:round].present?
    user = User.find(args[:user]) if args[:user].present?
    type = 'all'

    ActivityJob.perform_now(user.id.to_s, type, round.id.to_s)

    user.repositories.required.each do |repo|
      CommitJob.perform_now(user.id.to_s, type, repo.id.to_s, round.id.to_s)
    end

    activities_repo_ids = Activity.where(auto_score: nil, round: round, user: user)
                                  .distinct(:repository_id)
    Repository.find(activities_repo_ids).each do |repo|
      ScoringJob.perform_later(repo.id.to_s, round.id.to_s, 'activities')
    end

    commits_repo_ids = Commit.where(auto_score: nil, round: round, user: user)
                             .distinct(:repository_id)
    Repository.find(commits_repo_ids).each do |repo|
      ScoringJob.perform_later(repo.id.to_s, round.id.to_s, 'commits')
    end
  end

  desc 'update total points'
  task :total_points, [:user, :round] => :environment do |t, args|
    round = Round.find(args[:round]) if args[:round].present?
    user = User.find(args[:user]) if args[:user].present?

    round.subscriptions.where(user_id: user.id).each(&:update_points)
    
    subscription = user.subscriptions.where(round_id: round.id).first
    subscription.credit_points if subscription

    user.set(points: user.total_points)
  end
end
