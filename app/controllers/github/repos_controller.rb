class Github::ReposController < ApplicationController
  before_action :authenticate_user!

  def index
   find_repos("repos/#{current_user.id}", 'user')
   fetch_repo_data('org')
  end

  def orgs
    find_repos("repos/org/#{params[:org_name]}", 'org')
  end

  def sync
    %w(org user).each{|t| fetch_repo_data(t)}
  end

  private

  def find_repos(cache_key, type)
    repos = Rails.cache.read(cache_key)
    @repos = []

    if repos.present?
      @repos = JSON.parse(repos).map{|r| Hashie::Mash.new(r)}
    else
      fetch_repo_data(type)
    end
  end

  def fetch_repo_data(type)
    return if current_user.gh_sync_jobs[type].present?

    # Syching users repos
    job = UserGhReposJob.perform_later(current_user, type)
    current_user.gh_sync_jobs[type] = job.job_id
    current_user.save
  end

end
