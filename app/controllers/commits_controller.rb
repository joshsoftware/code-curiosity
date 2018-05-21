class CommitsController < ApplicationController
  before_action :user_commits, only: [:index]
  
  def index
    @commits = @commits.where(
                              :commit_date.gte => params[:from],
                              :commit_date.lte => params[:to],
                              message: /#{params[:query]}/
                             ) if params[:from] && params[:to] && params[:query]
    @commits = @commits.page(params[:page])
    if request.xhr?
      respond_to do|format|
        format.js
      end
    end
  end

  private

  def user_commits
    @commits = current_user.commits.asc(:commit_date)
  end
end
