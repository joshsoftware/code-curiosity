class JudgingController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_judge!
  before_action :find_score, only: [:rate]

  def commits
    @commits = current_round.commits
                            .in(repository: current_user.judges_repository_ids)
                            .page(params[:page])
                            .per(20)
  end

  def activities
    @activities = current_round.activities
                            .in(repository: current_user.judges_repository_ids)
                            .page(params[:page])
                            .per(20)
  end

  def rate
    if params[:rating].present?
      @score.update_attributes(value: params[:rating])
    else
      @score.destroy if @score
    end

    render nothing: true
  end

  private

  def find_score
    resource = if params[:type] == 'commit'
                 Commit.where(id: params[:id]).in(repository: current_user.judges_repository_ids).first
               else
                 Activity.where(id: params[:id]).in(repository: current_user.judges_repository_ids).first
               end

    @score = resource.scores.where(user: current_user).first

    if @score.nil?
      @score = resource.scores.build(user: current_user)
    end
  end
end
