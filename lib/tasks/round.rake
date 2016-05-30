namespace :round do
  desc "Creat next round"
  task :next => :environment do |t, args|
    round = Round.opened
    round.round_close
    opened_round = Round.opened
    per_batch = 1000

    0.step(User.count, per_batch) do |offset|
      User.limit(per_batch).skip(offset).each do |user|
        subscription = user.subscriptions.where(round_id: round.id).first
        subscription.credit_points if subscription
        user.subscribe_to_round(opened_round)
      end
    end
  end

  desc "Update Round scores" 
  task :update_scores,  [:round] => :environment do |t, args|
     round = args[:round].present? ? Round.find(args[:round]) : Round.opened
     round.subscriptions.all.each(&:update_points)
  end
end
