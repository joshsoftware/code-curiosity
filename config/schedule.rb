# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "/home/deploy/projects/codecuriosity/current/cron_log.log"

every :day, :at => '8:00pm' do
 rake "fetch_data:sync_repos"
end

every :day, :at => '10:00pm' do
  command 'backup perform --trigger code_curiosity_backup'
end

every :day, :at => '10:30am' do
  rake 'repo:delete_large_repositories'
end


every :day, :at => '00:00am' do
  rake 'fetch_commits'
end

every :day, :at => '01:00am' do
  rake 'score_and_reward'
end
