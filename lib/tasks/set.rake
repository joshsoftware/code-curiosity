namespace :set do
  desc "assign auto_score to score"
  task score: :environment do
    Commit.each do |commit|
      auto_score = commit.auto_score || 0.0
      commit.set(score: auto_score)
    end
  end

  desc 'set gh_repo_created_at for all repos'
  task gh_repo_created_at: :environment do
    Repository.required.each do |repo|
      while(!repo.set_gh_repo_created_at)
      end
    end
  end

  desc 'Calculate and set user points'
  task user_points: :environment do
    User.contestants.each do |user|
      credited_points = user.transactions.where(type: 'credit').sum(:points)
      user.set(points: credited_points)
    end
  end
end
