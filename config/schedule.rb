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

every '59 23 30 * *' do
  rake 'round:next'
end

every '59 23 31 * *' do
  rake 'round:next'
end

# TODO:
#every '1 1 25 * *' do
#  rake 'subscription:send_progress_emails'
#end

