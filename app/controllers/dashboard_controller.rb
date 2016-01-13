class DashboardController < ApplicationController
  before_action :authenticate_user!, only: [:repositories, :take_snapshot, :get_new_repos]

  def index
    @category = params[:category] || "score"
    @stats = @current_round.graph_data(@category)
  end

  def take_snapshot
    end_date =  Time.parse(params[:end_date]).end_of_day
    @current_round.end_date = end_date
    if @current_round.valid?
      @current_round.take_snapshot(end_date)
    end
    redirect_to root_path
  end

  def change_round
    session[:current_round] = Round.find(params[:round]).id
    redirect_to root_path
  end

  def webhook
    render :nothing
  end
end
