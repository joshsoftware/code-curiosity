class Github::ReposController < ApplicationController
  include RepoPagination
  include GhCacheHelper

  before_action :authenticate_user!

  def index
    @repos = cache_user_repos(params[:page] || 1)
    paginate(@repos.count_pages)
  end

  def orgs
    @repos = cache_org_repos(params[:org_name], params[:page] || 1)
    paginate(@repos.count_pages) if @repos.any?
  end

end
