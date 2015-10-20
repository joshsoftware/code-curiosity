class DashboardController < ApplicationController
  before_action :authenticate_user!, only: [:repositories, :take_snapshot]

  def index
    @category =  params[:category] || :score
    @stats = Round.graph_data(@current_round.id, @category)
  end

  def repositories
    @repos = Repository.all.order("name asc")
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
end
