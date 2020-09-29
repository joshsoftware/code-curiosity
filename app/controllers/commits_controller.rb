class CommitsController < ApplicationController
  before_action :user_commits, only: [:index, :reveal]

  def index
    from = params[:from].presence || Time.now.beginning_of_month
    to = params[:to].presence.try(:to_date).try(:end_of_day) || Time.now
    @commits = @commits.in_range(from, to)
                       .search_by(params[:query])
                       .page(params[:page])
                       .includes(:repository)
  end

  def reveal
    if params[:id]
      @commits.find(params[:id]).set(is_reveal: true)
    else
      @commits.set(is_reveal: true)
    end
    # render nothing: true # removed in rails 5.1
    head :ok
  end

  private

  def user_commits
    @commits = current_user.commits.desc(:commit_date)
  end
end
