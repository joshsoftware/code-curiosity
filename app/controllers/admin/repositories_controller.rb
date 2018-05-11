class Admin::RepositoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :load_repository, only: :update_ignore_field
  def index
    status = params[:ignored] || false
    @repos = Repository.parent.where(ignore: status, name: /#{params[:query]}/).
    order(name: :asc).page(params[:page])
    load_forks_count
    if request.xhr?
      respond_to do |format|
        format.js
      end
    end
  end

  def update_ignore_field
    @repo.update_attributes(ignore: params[:ignore_value])
    repositories = Repository.any_of({popular_repository_id: @repo.id}, {source_gh_id: @repo.gh_id})
    repositories.update_all(ignore: params[:ignore_value]) if repositories
  end

  def search
    if params[:q].blank?
      redirect_to admin_repositories_path
      return
    end

    @repos = Repository.required.parent.where(name: /#{params[:q]}/).asc(:name).page(params[:page])
    load_forks_count
    render :index
  end

  def load_forks_count
    @forks_repos_count = Repository.collection.aggregate [ { '$match' => {popular_repository_id: { '$in' => @repos.pluck(:id) }  } }, {'$group' => { '_id' => '$popular_repository_id', 'count' => { '$sum' => 1} } } ]
  end

  private

  def load_repository
    @repo = Repository.find(params[:id])
  end
end
