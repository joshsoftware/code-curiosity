desc 'set score and reward daily'
task score_and_reward: :environment do
  CommitReward.new(Date.today).calculate
end
