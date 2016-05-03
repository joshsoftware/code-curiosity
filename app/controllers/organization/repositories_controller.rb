class Organization::RepositoriesController < ApplicationController
  include OrganizationHelper

  before_action :find_org

  def index
    redirect_to :back
  end

  def sync
    unless @org.repo_syncing?
      OrgReposJob.perform_later(@org)
    end

    flash.now[:notice] = 'Your Repositories are getting in Sync. Please wait for sometime.'
  end
end
