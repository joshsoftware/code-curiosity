class UsersController < ApplicationController

  def index
    @users = current_user.is_judge? ? User.contestants : [current_user]
  end

  def show
    @user       = User.find(params[:id])
    @commits    = @user.commits.for_round(@current_round.id).includes(:scores).desc(:commit_date)
    @activities = @user.activities.for_round(@current_round.id).includes(:scores).desc(:commented_on)
  end
end
