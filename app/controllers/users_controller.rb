class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def index
    @users = current_user.is_judge? ? User.contestants : [current_user]
  end

  def show
    @user = User.find_by_slug(params[:id])
    @show_transactions = current_user == @user

    if @user
      render layout: current_user ? 'application' : 'public'
    else
      redirect_to root_url, notice: 'Invalid user name'
    end
  end

  def sync
    unless current_user.gh_data_syncing?
      CommitJob.perform_later(current_user, 'all')
      ActivityJob.perform_later(current_user, 'all')
    end
  end

  def update_notification
    user_params = params.fetch(:user).permit(:notify_monthly_progress, :notify_monthly_points)
    @user = User.find_by_slug(params[:id])
    @user.update(user_params)
  end

  def set_goal
    @goal = Goal.find(params[:goal_id])
    subscription = current_user.current_subscription

    if @goal.blank? || subscription.blank?
      redirect_to goals_path, notice: I18n.t('messages.not_found')
      return
    end

    current_user.set(goal_id: @goal.id)

    if subscription.goal
      message = I18n.t('goal.set_as_goal_next_month', { name: @goal.name, current_goal: subscription.goal.name })
    else
      message = I18n.t('goal.set_as_goal', { name: @goal.name })
      subscription.set(goal_id: @goal.id)
    end

    redirect_to goals_path, notice: message
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
    user.uid = "#{user.uid}-DELETED"
    user.auto_created = true
    user.save
    redirect_to root_url, notice: "Your account has been deleted successfully."
  end
end
