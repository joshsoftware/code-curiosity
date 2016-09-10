class DashboardController < ApplicationController
  include ContributionHelper
  before_action :authenticate_user!, except: [:webhook]

  def index
   contribution_data
  end

  def change_round
    session[:current_round] = Round.find(params[:id]).id
    redirect_back
  end

  def webhook
    render :nothing
  end
end
