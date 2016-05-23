class HomeController < ApplicationController
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

  def points
    subscription = current_user ? current_user.current_subscription(current_round) : nil

    @goal =  params[:goal_id].present? ? Goal.find(params[:goal_id]) : subscription.goal
    @goal = Goal.where(name: 'Hiker').first unless @goal

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

end
