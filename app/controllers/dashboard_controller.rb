class DashboardController < ApplicationController
  before_action :authenticate_user! #, only: [:repositories, :take_snapshot, :get_new_repos]

  def index
    #@category = params[:category] || "score"
    #@stats = @current_round.graph_data(@category)
  end

  def change_round
    session[:current_round] = Round.find(params[:id]).id
    redirect_to :back
  end

  def webhook
    render :nothing
  end
end
