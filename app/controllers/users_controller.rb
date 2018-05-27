class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def index
    @users = [current_user]
  end

  def show
    @user = User.find(params[:id])
    if @user
      render layout: current_user ? 'application' : 'public'
    else
      redirect_to root_url, alert: I18n.t('user.not_exist_in_system')
    end
  end

  def block_user
    user = User.find(params[:id])
    user.update(blocked: true)
  end

  def edit
  end

  def update
    if current_user.update user_params
      return
    end
    render :edit
  end

  def remove_handle
    current_user.update(twitter_handle: nil)
  end

  def sync
    unless current_user.gh_data_syncing?
      unless current_user.blocked
        CommitJob.perform_later(current_user.id.to_s, 'all')
        ActivityJob.perform_later(current_user.id.to_s, 'all')
      end
    end
  end

  def update_notification
    user_params = params.fetch(:user).permit(:notify_monthly_progress, :notify_monthly_points)
    @user = User.find(params[:id])
    @user.update(user_params)
  end

  def search
    users = if params[:query].present?
              User.where(github_handle: /^#{params[:query]}/i).limit(10).only(:id, :github_handle, :avatar_url, :name)
            else
              []
            end

    render json: users
  end

  def destroy
    user = current_user

    sign_out current_user

    # We cannot delete the user completely, because there are plenty of associations.
    # So, we manipulate the UID and set auto_created: true, so that no data will be fetched.
    user.update({deleted_at: Time.now, auto_created: true, active: false, blocked: user.blocked ? false : user.blocked })
    redirect_to root_url, notice: "Your account has been deleted successfully."
  end

  private

  def user_params
    params.require(:user).permit(:twitter_handle)
  end

end
