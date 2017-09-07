class Github::ReposController < ApplicationController
  before_action :authenticate_user!

  def sync
    unless current_user.repo_syncing?
      UserReposJob.perform_later(current_user.id.to_s) unless current_user.blocked
    end
  end
end
