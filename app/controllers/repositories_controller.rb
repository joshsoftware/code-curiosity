class RepositoriesController < ApplicationController

  def index
    @repos = current_user.is_judge? ? Repository.all : current_user.repositories
  end

  def create
    Repository.add_new(params[:repository], current_user)   
    redirect_to repositories_path
  end

  def sync
    CommitJob.perform_later(current_user.id.to_s, params[:repository_id])
    ActivityJob.perform_later(current_user.id.to_s)
    flash[:notice] = "Your Repositories are getting in Sync. Please wait for sometime."
    redirect_to repositories_path
  end

end
