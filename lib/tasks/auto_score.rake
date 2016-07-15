desc 'auto scoring commits and activities'
task :auto_score, [:round] => :environment do |t, args|
  round = args[:round] ? Round.find(args[:round]) : Round.opened

  commits_repo_ids = Commit.where(auto_score: nil, round: round).distinct(:repository_id)
  Repository.find(commits_repo_ids).each do |repo|
    ScoringJob.perform_later(repo, round, 'commits')
  end

  activities_repo_ids = Activity.where(auto_score: nil, round: round).distinct(:repository_id)
  Repository.find(activities_repo_ids).each do |repo|
    ScoringJob.perform_later(repo, round, 'activities')
  end
end
