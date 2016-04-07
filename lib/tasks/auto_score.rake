desc 'auto scoring commits and activities'
task :auto_score, [:round] => :environment do |t, args|
  round = args[:round] ? Round.find(args[:round]) : Round.find_by({status: 'open'})

  Repository.all.each do |repo|
    repo.score_commits(round)
  end
end
