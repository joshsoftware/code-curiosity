namespace :round do
  desc "Creat next round"
  task :next => :environment do |t, args|
    round = Round.find_by({status: 'open'})
    round.round_close

    next_round = Round.find_by({status: 'open'})

    User.all.each do |user|
      user.subscriptions.find_or_create_by(round: next_round)
    end
  end
end
