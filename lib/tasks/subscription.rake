namespace :subscription do
  desc "TODO"
  task send_email: :environment do
      SubscriptionMailer.subscription_email(User.all.to_a[1]).deliver_now
  end

end
