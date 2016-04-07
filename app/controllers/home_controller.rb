class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to dashboard_path
      return
    end
  end

  def leaderboard
    @users = User.order(total_points: :desc).page(params[:page]).per(10)

    if user_signed_in?
      render layout: 'application'
    else
      render layout: 'info'
    end
  end
end
