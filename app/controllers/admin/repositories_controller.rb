class Admin::RepositoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @status = params[:ignored] || false
    @repos = Repository.where(ignore: @status, name: /#{params[:query]}/).order(name: :asc)
    .page(params[:page])
    if request.xhr?
      respond_to do |format|
        format.js
      end
    end
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

  def update_ignore_field
    @repo_to_update = Repository.find(params[:id])
    ignore_value = params[:ignore_value]
    @repo_to_update.update_attributes(ignore: ignore_value)
  end

  def search
    if params[:q].blank?
      redirect_to admin_repositories_path
      return
    end

    @repos = Repository.required.where(name: /#{params[:q]}/).asc(:name).page(params[:page])
    render :index
  end
end
