require File.join(Rails.root, 'app', 'jobs', 'application_job.rb')
ActiveJob::Base.queue_adapter = :sidekiq
