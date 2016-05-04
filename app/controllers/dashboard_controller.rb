class DashboardController < ApplicationController
  before_action :authenticate_user!, except: [:webhook]

  def index
  end

  def change_round
    session[:current_round] = Round.find(params[:id]).id
    redirect_back
  end

  def webhook
    render :nothing
  end
end
