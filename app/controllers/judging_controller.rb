class JudgingController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_judge!
  before_action :find_resource, only: [:rate, :comment, :comments]

  def commits
    @commits = current_round.commits
                            .page(params[:page])
                            .per(20)
    #                       .in(repository: current_user.judges_repository_ids)
  end

  def activities
    @activities = current_round.activities
                            .page(params[:page])
                            .per(20)
    #                       .in(repository: current_user.judges_repository_ids)
  end

  def rate
    @score = @resource.scores.where(user: current_user).first

    if @score.nil?
      @score = @resource.scores.build(user: current_user)
    end

    if params[:rating].present?
      @score.update_attributes(value: params[:rating].to_i)
    else
      @score.destroy if @score
    end

    @resource.set_judges_avg_score

    render nothing: true
  end

  def comments
    @comments = @resource.comments
  end

  def comment
    @comment = @resource.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      @comment = Comment.new
    else
      @resource.reload
    end

    @comments = @resource.comments

    render 'comments/create'
  end

  private

  def find_resource
    @resource = if params[:type] == 'commit'
                 Commit.where(id: params[:id]).first
                 #Commit.where(id: params[:id]).in(repository: current_user.judges_repository_ids).first
               else
                 Activity.where(id: params[:id]).first
                 #Activity.where(id: params[:id]).in(repository: current_user.judges_repository_ids).first
               end

    unless @resource
      render nothing: true, status: 404
    end

    if params[:rating].to_i > @resource.max_rating
      render nothing: true, status: 401
    end
  end

  def comment_params
     params.require(:comment).permit(:content, :is_public)
  end

end
