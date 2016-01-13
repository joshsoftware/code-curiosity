class UsersController < ApplicationController

  def index
    @users = current_user.is_judge? ? User.contestants : [current_user]
  end

  def show
    @user       = User.find(params[:id])
    @commits    = @user.commits.for_round(@current_round.id).includes(:scores).desc(:commit_date)
    @activities = @user.activities.for_round(@current_round.id).includes(:scores).desc(:commented_on)
  end

  def mark_as_judge
    User.find(params[:user_id]).set(is_judge: params[:flag])
    redirect_to users_path
  end

  def sync
    CommitJob.perform_later(params[:user_id])
    ActivityJob.perform_later(params[:user_id])
    flash[:notice] = "Your Repositories are getting in Sync. Please wait for sometime."
    redirect_to user_path(params[:user_id]) 
  end
end
