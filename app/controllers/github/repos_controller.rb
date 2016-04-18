class Github::ReposController < ApplicationController
  before_action :authenticate_user!

  def index
    find_repos("repos/#{current_user.id}", 'user')
  end

  def orgs
    find_repos("repos/org/#{params[:org_name]}", 'org')
  end

  def sync
    %w(user org).each{|t| fetch_repo_data(t)}
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
    return if current_user.repo_syncing?(type)

    # Syching users repos
    UserGhReposJob.perform_later(current_user, type)

    if type == 'user'
      current_user.last_repo_sync_at = Time.now
    else
      current_user.last_org_repo_sync_at = Time.now
    end

    current_user.save
  end

end
