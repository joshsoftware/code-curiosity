class DashboardController < ApplicationController
  before_action :authenticate_user!, only: [:repositories, :take_snapshot, :get_new_repos]

  def index
    @category =  params[:category] || "score"
    @stats = Round.graph_data(@current_round.id, @category)
  end

  def repositories
    @repos = Repository.all.order("name asc")
  end

  def get_new_repos
    repos  = Repository.fetch_remote_repos.as_json(only: [:name, :description, :watchers])
    existing_repos = Repository.all.pluck(:name)
    new_repos = repos.collect{|r| r["name"]} - existing_repos 
    repos.each do |repo|
      Repository.create(name: repo["name"], description: repo["description"], watchers: repo["watchers"]) if new_repos.include?(repo["name"])
    end
    redirect_to repositories_path
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
