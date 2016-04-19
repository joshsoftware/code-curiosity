namespace :fetch_data do
  desc "Fetch code-curiosity github repositories commits and activities periodically."
  task :commits_and_activities, [:type] => :environment do |t, args|
    type = args[:type] || 'daily'
    per_batch = 1000

    0.step(User.count, per_batch) do |offset|
      User.limit(per_batch).skip(offset).each do |user|
        CommitJob.perform_later(user, type)
        ActivityJob.perform_later(user, type)
      end
    end
  end
end
