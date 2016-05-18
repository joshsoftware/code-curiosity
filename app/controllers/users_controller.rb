class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def index
    @users = current_user.is_judge? ? User.contestants : [current_user]
  end

  def show
    @user = User.find_by_slug(params[:id])

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

    redirect_to repositories_path, notice: I18n.t('messages.repository_sync')
  end

  def set_goal
    @goal = Goal.find(params[:goal_id])

    unless @goal
      redirect_to goals_path, notice: I18n.t('messages.not_found')
      return false
    end

    current_user.set(goal_id: @goal.id)
    message = I18n.t('goal.set_as_goal', { name: @goal.name })

    if subscription = current_user.current_subscription
      if subscription.goal
        message = I18n.t('goal.set_as_goal_next_month', { name: @goal.name, current_goal: subscription.goal.name })
      else
        subscription.set(goal_id: @goal.id)
      end
    end

    redirect_to user_path(current_user), notice: message
  end
end
