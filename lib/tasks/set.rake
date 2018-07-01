namespace :set do
  desc "assign auto_score to score"
  task score: :environment do
    Commit.each do |commit|
      auto_score = commit.auto_score || 0.0
      commit.set(score: auto_score)
    end
  end

  desc 'set gh_repo_created_at and language for all repos'
  task repo_fields: :environment do
    Repository.required.each do |repo|
      while(!repo.set_fields)
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

  desc 'Remove forked repos'
  task remove_forked_repos: :environment do
    Repository.where(:source_gh_id.ne => nil).destroy_all
  end

  desc 'Set user badges'
  task badges: :environment do
    User.contestants.each do |user|
      user.commits.includes(:repository).each do |commit|
        language = commit.repository&.language
        if language
          user.badges[language] = 0 if user.badges[language].nil?
          user.badges[language] += commit.score
          user.save
        end
      end
    end
  end

  desc 'Create last month transaction'
  task create_last_month_transaction: :environment do
    last_month = Time.now.beginning_of_month.last_month..Time.now.end_of_month.last_month
    User.contestants.each do |user|
      last_month_points = user.commits.where(commit_date: last_month).sum(&:score)
      user.create_transaction(
        type: 'credit',
        points: last_month_points,
        description: "Round: #{Time.now.strftime('%B %Y')}",
        transaction_type: 'Round'
      )
    end
  end
end
