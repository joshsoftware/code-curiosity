module UsersHelper

  def logged_in_user?
    current_user == @user
  end

  def github_points_options
    REDEEM['github_redeem_amounts'].collect do |amount|
      ["$#{amount}", amount]
    end
  end

  def remove_prefix(twitter_handle)
    twitter_handle[1..-1]
  end

  def amount_earned(user)
    user.transactions.where(type: 'debit').sum(:amount).abs
  end
end
