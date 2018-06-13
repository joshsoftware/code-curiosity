namespace :set do
  desc "assign auto_score to score"
  task score: :environment do
    Commit.each do |commit|
      auto_score = commit.auto_score || 0.0
      commit.set(score: auto_score)
    end
  end
end
