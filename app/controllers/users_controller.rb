class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = current_user.is_judge? ? User.contestants : [current_user]
  end

  def show
    @user = current_user
  end

  def mark_as_judge
    User.find(params[:user_id]).set(is_judge: params[:flag])
    redirect_to users_path
  end

  def sync
    CommitJob.perform_later(params[:user_id])
    ActivityJob.perform_later(params[:user_id])
    redirect_to user_path(params[:user_id]), :notice => I18.t('messages.repository_sync')
  end
end
