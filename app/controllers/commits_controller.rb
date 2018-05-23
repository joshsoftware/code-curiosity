class CommitsController < ApplicationController
  before_action :user_commits, only: [:index]
  
  def index
    @commits = @commits.in_range(params[:from], params[:to])
                       .search_by(params[:query])
                       .page(params[:page])
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
