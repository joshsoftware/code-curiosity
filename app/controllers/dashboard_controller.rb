class DashboardController < ApplicationController
  before_action :authenticate_user!, except: [:webhook]

  def index
    subscriptions = current_user.subscriptions.where(:created_at.gt => Date.parse("Feb 2016")).asc(:created_at)
    @xAxis = []
    @commits = []
    @activities = []
    @points = []
    subscriptions.map{|s| @xAxis << s.round.name; @commits << s.commits_count; @activities << s.activities_count; @points << s.points}
  end

  def change_round
    session[:current_round] = Round.find(params[:id]).id
    redirect_back
  end

  def webhook
    render :nothing
  end
end
