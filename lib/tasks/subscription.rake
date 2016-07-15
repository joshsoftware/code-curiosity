namespace :subscription do
  desc "Send subscription renew notfication email "
  task send_email: :environment do
    #User.all.each do |user| 
    #  SubscriptionMailer.subscription_email(user).deliver_now
    #end
  end

  desc "Send Progress emails"
  task send_progress_emails: :environment do
    users = User.contestants
    round = Round.opened
    per_batch = 1000

    0.step(users.count, per_batch) do |offset|
      users.limit(per_batch).skip(offset).each do |user|
        SubscriptionMailer.progress(user, round).deliver_later
      end
    end
  end

  desc "Invite users to redeem"
  task redeem_points: :environment do
     range = [ 
       [85, 100, "You're almost there!"],
       [100, 150, "You've done it!" ],
       [150, 1000, "Splurge!"]
     ].each do |r|
       User.where(:points.gte => r[0], :points.lt => r[1]).each do |user|
         SubscriptionMailer.redeem_points(user, r[2]).deliver_later
       end
     end
  end
end
