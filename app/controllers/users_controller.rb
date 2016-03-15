class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def index
    @users = current_user.is_judge? ? User.contestants : [current_user]
  end

  def show
    @user = User.where(id: params[:id]).first || User.where(github_handle: params[:id]).first

    if @user
      render layout: current_user ? 'application' : 'public'
    else
      redirect_to root_url, notice: 'Invalid user name'
    end
  end

  def sync
    CommitJob.perform_later(params[:user_id])
    ActivityJob.perform_later(params[:user_id])
    redirect_to user_path(params[:user_id]), :notice => I18.t('messages.repository_sync')
  end
end
