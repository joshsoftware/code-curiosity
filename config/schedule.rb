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

every :day, :at => '12:00am' do
  rake "fetch_data:commits_and_activities"
end

every :day, :at => '3:00am' do
 rake "auto_score"
end

every :day, :at => '6:00am' do
 rake "round:update_scores"
end

every :day, :at => '8:00pm' do
 rake "fetch_data:sync_repos"
end

every :day, :at => '10:00pm' do
  command 'backup perform --trigger code_curiosity_backup'
end

every '59 23 27-31 * *' do
  rake "round:update_scores"
  rake 'round:next'
end

every '1 1 21 * *' do
  # rake 'subscription:send_progress_emails'
end

every '1 10 7 * *' do
  # rake 'subscription:redeem_points'
end

every :day, :at => '10:30am' do
  rake 'repo:delete_large_repositories'
end
