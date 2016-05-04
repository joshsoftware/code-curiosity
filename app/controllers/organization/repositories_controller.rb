class Organization::RepositoriesController < ApplicationController
  include OrganizationHelper

  before_action :find_org

  def index
    redirect_back
  end

  def sync
    unless @org.repo_syncing?
      OrgReposJob.perform_later(@org)
    end

    flash.now[:notice] = I18n.t('repositories.github_sync')
  end
end
