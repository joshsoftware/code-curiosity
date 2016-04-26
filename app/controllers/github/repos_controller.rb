class Github::ReposController < ApplicationController
  before_action :authenticate_user!

  def sync
    unless current_user.repo_syncing?
      UserReposJob.perform_later(current_user)
    end
  end
end
