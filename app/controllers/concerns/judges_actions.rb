module JudgesActions
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

  def rate
    @resource.rate(current_user, params[:rating])
    render nothing: true
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :is_public)
  end
end
