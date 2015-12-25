class RepositoriesController < ApplicationController

  def index
    @repos = current_user.is_judge? ? Repository.all : current_user.repositories
  end

  def create
    Repository.add_new(params[:repository], current_user)   
    redirect_to repositories_path
  end

end
