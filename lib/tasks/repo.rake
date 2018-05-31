require 'find'

namespace :repo do
  desc "Delete the cloned repositories having size greater than SIZE_LIMIT MB"
  task delete_large_repositories: :environment do
    repos = Dir.entries(Rails.root.join(SCORING_ENGINE_CONFIG[:repositories]).to_s) - ['.','..']
    repos.each do |repo|
      total_size = 0

      repo_path = Rails.root.join(SCORING_ENGINE_CONFIG[:repositories]+"/"+repo)
      Find.find(repo_path) do |path|
        begin
          if FileTest.directory?(path)
            if File.basename(path)[0] == ?.
              Find.prune
            else
              next
            end
          else
            total_size += FileTest.size(path)
          end
        rescue
          total_size += 0
        end
      end
      FileUtils.rm_r(repo_path) if (total_size/1024000.0).round > REPOSITORY_CONFIG['max_size']
    end
  end

=begin
  desc "delete cloned repository whose commits got scored"
  task delete_repository_dir: :environment do
    # get all the repository ids whose commits belong to the current round
    # repository_ids = Commit.pluck(:repository_id).uniq
    repository_ids = Round.opened.commits.pluck(:repository_id).uniq
    # get those repository ids whose commits from the current round are not scored yet
    unscored_repository_ids = Round.opened.commits.where(auto_score: nil).pluck(:repository_id).uniq
    # Remove all those repository directories which are not required for the current round
    # if their directory exists
    (repository_ids - unscored_repository_ids).each do |id|
      path = "#{Rails.root.join(SCORING_ENGINE_CONFIG[:repositories]).to_s}/#{id}"
      FileUtils.rm_r(path) if Dir.exists?(path)
    end
  end
=end

end
