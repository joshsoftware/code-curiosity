namespace :notify_all do
  desc "Notify users about change of terms of service"
  task notify_contestants: :environment do
    users = User.contestants.any_of({notify_monthly_points: nil}, {notify_monthly_points: true}).where(:points.gte => 85, :points.lt => 1000).pluck(:id)
    User.contestants.where(:id.nin => users).each do |user|
      SubscriptionMailer.redeem_points(user, "Change of Terms of Service")
    end
  end
end
