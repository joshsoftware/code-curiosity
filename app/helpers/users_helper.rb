module UsersHelper

  def logged_in_user?
    current_user == @user
  end

  def github_points_options
    REDEEM['github_redeem_amounts'].collect do |v|
      [
        "$#{v} - #{v * REDEEM['one_dollar_to_points'] * 2} points",
        v * REDEEM['one_dollar_to_points'] * 2
      ]
      #v*REDEEM['one_dollar_to_points']]
    end
  end

  def remove_prefix(twitter_handle)
    twitter_handle[1..-1]
  end

  def amount_earned(user)
    user.transactions.where(type: 'debit').sum(:amount).abs
  end
end
