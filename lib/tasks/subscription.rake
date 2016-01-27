namespace :subscription do
  desc "TODO"
  task send_email: :environment do
      SubscriptionMailer.subscription_email(User.first).deliver
  end

end
