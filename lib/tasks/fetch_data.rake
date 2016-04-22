namespace :fetch_data do
  desc "Fetch code-curiosity github repositories commits and activities periodically."
  task :commits_and_activities, [:type] => :environment do |t, args|
    type = args[:type] || 'daily'
    puts "Running for #{type}"

    per_batch = 1000
    users = User.where(auto_created: false)

    0.step(users.count, per_batch) do |offset|
      users.limit(per_batch).skip(offset).each do |user|
        CommitJob.perform_later(user, type)
        ActivityJob.perform_later(user, type)
      end
    end
  end

  desc "Fetch data for all rounds"
  task :all_rounds => :environment do |t, args|
    users = User.where(auto_created: false)
    type = 'all'
    
    User.where(auto_created: false).each do |user|
      user.subscriptions.each do |s|
        CommitJob.perform_later(user, type, nil, s.round)
        ActivityJob.perform_later(user, type, s.round)
      end
    end
  end

end
