class DashboardController < ApplicationController

  def index
    @category =  params[:category] || "Team"
    @start_date =  params[:start_date] || (Time.now - 1.month).strftime("%d/%m/%Y")
    @end_date =  params[:end_date] || Time.now.strftime("%d/%m/%Y")
    @data = Commit.get_data(@category, @start_date, @end_date)
  end

  def repositories
    @repos = Repository.fetch_remote_repos.as_json(only: [:name, :description, :watchers])
  end
end
