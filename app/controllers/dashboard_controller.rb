class DashboardController < ApplicationController
  before_action :authenticate_user!, only: [:repositories]

  def index
    if current_user
      @category =  params[:category] || "Team commits"
      @start_date =  params[:start_date] || current_month
      @end_date =  params[:end_date] || Time.now.strftime("%d/%m/%Y")
      @stats = Commit.graph_data(@start_date, @end_date)
    else
      @round_periods = Snapshot.order("from_date desc")
      @round = params[:round] || (@round_periods.first ? @round_periods.first.round_period : nil)
      @stats = Snapshot.graph_data(@round)
    end
  end

  def repositories
    @repos = Repository.all.order("name asc")
  end

  private

  def current_month
    (Time.now - 1.month).strftime('%d/%m/%Y')
  end
end
