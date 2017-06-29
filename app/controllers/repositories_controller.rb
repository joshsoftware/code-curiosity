class RepositoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_repo, only: [:destroy, :sync]

  def index
    @repos = current_user.repositories
  end

  def new
    @repo = Repository.new
    render 'edit'
  end

  def create
    @repo = Repository.add_new(params[:repository], current_user)
  end

  def edit
  end

  def update
    @repo.update_attributes(repository_params)

    if @repo.valid?
      redirect_to repositories_path, notice: 'Successfully updated'
    else
      redirect_to repositories_path, alert: ''
    end

    render 'create'
  end

  def destroy
    current_user.repositories.delete(@repo)
    redirect_to repositories_path
  end

  def sync
    unless current_user.gh_data_syncing?
      CommitJob.perform_later(current_user.id.to_s, 'all', @repo.id.to_s)
    end

    flash[:notice] = I18n.t('repositories.github_sync')
    redirect_to repositories_path
  end

  private

  def find_repo
    @repo = current_user.repositories.where(id: params[:id] || params[:repository_id]).first

    unless @repo
      flash[:alert] = 'Repository not found.'
      redirect_to repositories_path
    end
  end

  def repository_params
    params.fetch(:repository).permit(:source_url, :popular_repository_url)
  end

end
