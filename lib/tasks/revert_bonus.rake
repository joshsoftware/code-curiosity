namespace :revert_bonus do
  desc 'revert royaly bonus assigned to user after taking a subscription'
  # Remove all transaction created when user became an sponsorer and his/her all points
  # got converted into royalty bonus.
  task revert_subscription_royalty_bonus: :environment do
    # Taking all the sponsorers
    sponsorers = User.where(:id.in => SponsorerDetail.pluck(:user_id).uniq)
    # Fetching all royalty transactions formed during sponsorer creating
    royalty_transactions = Transaction.where(transaction_type: :royalty_bonus, :user_id.in => sponsorers.pluck(:id), :created_at.gte => DateTime.parse('01/08/2017'))
    points = royalty_transactions.collect{ |x| -x.points }
    # Fetching all redeem transactions formed during sponsorer creating
    redeem_transactions = Transaction.where(transaction_type: :redeem_points, :points.in => points, :created_at.gt => DateTime.parse('01/08/2017'))
    # Deleting fetched royalty transactions
    royalty_transactions.destroy_all
    # Deleting fetched redeem transactions
    redeem_transactions.destroy_all
  end
end
