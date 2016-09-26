class HomeController < ApplicationController
  include HomeHelper

  #load the before_actions only if the user is not logged in.
  before_action :featured_groups, only: [:index], unless: proc { user_signed_in? }
  before_action :featured_groups_size, only: [:index], unless: proc { user_signed_in? }
  before_action :multi_line_chart, only: [:index], unless: proc { user_signed_in? }

  def index
    if user_signed_in?
      redirect_to dashboard_path
      return
    end
  end

  def leaderboard
    @subscriptions = current_round.subscriptions
                                  .where(:points.gt => 0)
                                  .order(points: :desc)
                                  .page(1).per(5)

    if user_signed_in?
      render layout: 'application'
    else
      render layout: 'info'
    end
  end

  def trend
    subscription = current_user ? current_user.current_subscription(current_round) : nil

    @goal = if params[:goal_id].present?
              Goal.where(id: params[:goal_id]).first
            elsif subscription
              subscription.goal
            end
    @goal = Goal.default_goal unless @goal

    @points = current_round.subscriptions
                           .where(goal_id: @goal.id)
                           .order(points: :desc)
                           .pluck(:points)

    if current_user
      if subscription && subscription.goal == @goal
        @user_points = subscription.points
      end
    end

    if user_signed_in?
      render layout: 'application'
    else
      render layout: 'info'
    end
  end

  # methods from the HomeHelper module are public and need to be private
  private :featured_groups, :featured_groups_size

end
