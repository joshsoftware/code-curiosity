class DashboardController < ApplicationController
  before_action :authenticate_user!, only: [:repositories]

  def index
    @category =  params[:category] || "Team commits"
    @teams = Team.all.pluck(:name)
    if current_user
      @start_date =  params[:start_date] || (Time.now - 1.month).strftime("%d/%m/%Y")
      @end_date =  params[:end_date] || Time.now.strftime("%d/%m/%Y")
      @data, @title = Commit.get_graphdata(@category, @start_date, @end_date)
    else
      @round_periods = Snapshot.order("from_date desc")
      @round = params[:round] || (@round_periods.first ? @round_periods.first.round_period : nil)
      @data, @title = Snapshot.get_graphdata(@category, @round)
    end
  end

  def repositories
    @repos = Repository.all.order("name asc")
  end

  def team
    @start_date = current_month
    @end_date = Time.now.strftime("%d/%m/%Y")
    @data, @title = Commit.get_data("Team", @start_date, @end_date)
    render layout: 'widget'
  end

  def individual
    @start_date = current_month
    @end_date = Time.now.strftime("%d/%m/%Y")
    @data, @title = Commit.get_data("Individual", @start_date, @end_date)
    render layout: 'widget'
  end

  private

  def current_month
    (Time.now - 1.month).strftime('%d/%m/%Y')
  end
end
