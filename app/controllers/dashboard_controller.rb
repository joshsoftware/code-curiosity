class DashboardController < ApplicationController
  before_action :authenticate_user!, only: [:repositories]

  def index
    @category =  params[:category] || :commit
    @rounds = Round.order(from_date: :desc)
    @round = params[:round] || Round.find_by(status: "open").try(:id)
    @stats = Round.graph_data(@round, @category)
  end

  def repositories
    @repos = Repository.all.order("name asc")
  end

  private

  def current_month
    (Time.now - 1.month).strftime('%d/%m/%Y')
  end
end
