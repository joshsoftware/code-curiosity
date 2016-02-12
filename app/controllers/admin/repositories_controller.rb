class Admin::RepositoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @repos = Repository.order(name: :asc).page(params[:page])
  end

  def assign_judge
    @repo = Repository.find(params[:id])
    @judges = User.judges
  end

  def add_judges
   @repo = Repository.find(params[:id])
   @repo.judges = User.find(params[:judges])
   @repo.save
  end
end
