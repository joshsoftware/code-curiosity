class Admin::RepositoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :load_repository, only: [ :assign_judge, :add_judges, :update_ignore_field ]

  def index 
    status = params[:ignored] || false
    @repos = Repository.where(ignore: status, name: /#{params[:query]}/).
    order(name: :asc).page(params[:page])
    if request.xhr?
      respond_to do |format|
        format.js
      end
    end
  end

  def assign_judge
    @judges = User.judges
  end

  def add_judges
   @repo.judges = User.find(params[:judges])
   @repo.save
  end

  def update_ignore_field
    @repo.update_attributes(ignore: params[:ignore_value])
  end

  def search
    if params[:q].blank?
      redirect_to admin_repositories_path
      return
    end

    @repos = Repository.required.where(name: /#{params[:q]}/).asc(:name).page(params[:page])

    render :index
  end

  private
   
  def load_repository
    @repo = Repository.find(params[:id])
  end
end
