module UsersHelper

  def logged_in_user?
    current_user == @user
  end

  def github_points_options
    REDEEM['github_redeem_amounts'].collect do |v|
      [
        "$#{v} - #{v * redeem_request_value(current_user, REDEEM['one_dollar_to_points'])} points",
        v * redeem_request_value(current_user, REDEEM['one_dollar_to_points'])
      ]
      #v*REDEEM['one_dollar_to_points']]
    end
  end

  def remove_prefix(twitter_handle)
    twitter_handle[1..twitter_handle.length]
  end
end
