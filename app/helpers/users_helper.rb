module UsersHelper

  def logged_in_user?
    current_user == @user
  end

  def github_points_options
    REDEEM['github_redeem_amounts'].collect do |v|
      ["$#{v} - #{v*REDEEM['one_dollar_to_points']} points",  v*REDEEM['one_dollar_to_points']]
    end
  end
end
