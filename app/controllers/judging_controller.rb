class JudgingController < ApplicationController
  include JudgesActions

  before_action :authenticate_user!
  before_action :authenticate_judge!
  before_action :find_resource, only: [:rate, :comment, :comments]

  def commits
    @commits = current_round.commits
                            .page(params[:page])
                            .per(20)
                            .order(commit_date: :desc)
    #                       .in(repository: current_user.judges_repository_ids)
  end

  def activities
    @activities = current_round.activities
                            .page(params[:page])
                            .per(20)
                            .order(commented_on: :desc)
    #                       .in(repository: current_user.judges_repository_ids)
  end

  private

  def find_resource
    @resource = if params[:type] == 'commits'
                  Commit.where(id: params[:resource_id]).first
                  #Commit.where(id: params[:id]).in(repository: current_user.judges_repository_ids).first
                else
                  Activity.where(id: params[:resource_id]).first
                  #Activity.where(id: params[:id]).in(repository: current_user.judges_repository_ids).first
                end

    unless @resource
      render nothing: true, status: 404
    end

    if params[:rating].to_i > @resource.max_rating
      render nothing: true, status: 401
    end
  end
end
