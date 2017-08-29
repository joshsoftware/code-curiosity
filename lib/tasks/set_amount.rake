namespace :set_amount do
  # task to populate amount field in transaction
  desc "set amount field for all transactions"
  task set_amount_for_transactions: :environment do

    # transactions before 2nd of august
    Transaction.where(:created_at.lt => DateTime.parse('02/08/2017')).each do |transaction|
      transaction.set(amount: transaction.points.to_f/REDEEM['one_dollar_to_points'])
    end

    #transactions after and on 2nd of august
    Transaction.where(:created_at.gte => DateTime.parse('02/08/2017')).each do |transaction|
      flag = true
      # transaction creation time lies in between any active sponsorship then set amount
      # according to subscription.
      transaction.user.sponsorer_details.each do |sponsorer_detail|
        if transaction.created_at >= sponsorer_detail.subscribed_at && transaction.created_at <= sponsorer_detail.subscription_expires_at
          transaction.set(amount: transaction.points.to_f/SUBSCRIPTIONS[sponsorer_detail.sponsorer_type.downcase])
          flag = false
        end
      end
      # transaction time doesn't lies in between any active sponsorship then it is carried
      # out during free plan
      transaction.set(amount: transaction.points.to_f/SUBSCRIPTIONS['free']) if flag
    end

    Transaction.where(:created_at.gte => DateTime.parse('01/08/2017'), transaction_type: 'royalty_bonus').each do |transaction|
      # take the very first sponsor plan taken by user and check whether it is taken within
      # a month after sign up
      if transaction.user.sponsorer_details.any? && transaction.user.sponsorer_details.asc(:created_at).first.created_at - transaction.user.created_at <= 1.month
        transaction.set(amount: transaction.points.to_f/SUBSCRIPTIONS[sponsorer_detail.sponsorer_type.downcase])
      else
        transaction.set(amount: transaction.points.to_f/SUBSCRIPTIONS['free'])
      end
    end
    # To keep up with the records of redeem requests all redeem transaction between 1st and
    # 2nd of August are done as per their subscription plan. As all redeem requests between
    # mentioned time are from free plan the amount assigned is $1:20 points
    Transaction.where(transaction_type: 'redeem_points', :created_at.gte => DateTime.parse('01/08/2017'), :created_at.lt => DateTime.parse('02/08/2017')).each do |transaction|
      transaction.set(amount: transaction.points.to_f/SUBSCRIPTIONS['free'])
    end
  end
end
