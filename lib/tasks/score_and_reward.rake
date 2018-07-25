desc 'set score and reward daily'
task :score_and_reward, [:from_date, :to_date] => :environment do |t, args|
  from_date = args[:from_date].present? ? args[:from_date].to_date : Date.yesterday
  to_date = args[:to_date].present? ? args[:to_date].to_date : Date.yesterday
  date = from_date..to_date

  date.each{ |date| CommitReward.new(date).calculate }
end
