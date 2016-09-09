class ActivitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    get_commits
    get_activities
  end

  def commits
    get_commits
  end

  def activities
    get_activities
  end

  private

  def get_commits
    @commits  = current_user.commits
    .for_round(@current_round.id)
    .desc(:commit_date).page(params[:page])
  end

  def get_activities
    @activities = current_user.activities
    .for_round(@current_round.id)
    .desc(:commented_on).page(params[:page])
  end
end
