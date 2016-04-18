namespace :fetch_data do
  desc "Fetch code-curiosity github repositories commits and activities periodically."
  task :commits_and_activities => :environment do |t, args|
    user = User.all.each do |user|
      CommitJob.perform_later(user)
      ActivityJob.perform_later(user)
    end
  end
end
