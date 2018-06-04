class HomeController < ApplicationController
  include HomeHelper

  #load the before_actions only if the user is not logged in.
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

end
