class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to dashboard_path
      return
    end
  end

  def leaderboard
    subscriptions = current_round.subscriptions
                                 .where(:points.gt => 0)
                                 .order(points: :desc)
                                 .page(1).per(5)

    @users = subscriptions.map(&:user)

    if user_signed_in?
      render layout: 'application'
    else
      render layout: 'info'
    end
  end
end
