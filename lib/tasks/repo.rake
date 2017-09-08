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

end
