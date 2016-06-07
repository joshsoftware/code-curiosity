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

    0.step(users, per_batch) do |offset|
      users.limit(per_batch).skip(offset).each do |user|
        SubscriptionMailer.progress(user, round).deliver_later
      end
    end
  end

end
