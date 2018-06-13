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
end
