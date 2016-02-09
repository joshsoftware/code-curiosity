require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def comment
    @comment ||= Comment.new
  end

  def test_valid
    assert comment.valid?
  end
end
