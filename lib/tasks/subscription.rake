namespace :subscription do
  desc "Send subscription renew notfication email "
  task send_email: :environment do
    #User.all.each do |user| 
    #  SubscriptionMailer.subscription_email(user).deliver_now
    #end
  end

end
