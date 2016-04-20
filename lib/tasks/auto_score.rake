desc 'auto scoring commits and activities'
task :auto_score, [:round] => :environment do |t, args|
  round = args[:round] ? Round.find(args[:round]) : Round.opened

  Repository.users_repos.each do |repo|
    ScoringJob.perform_later(repo, round)
  end
end
