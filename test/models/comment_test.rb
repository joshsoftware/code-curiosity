require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @comment = Comment.new(content: 'abc')
  end

  test 'valid comment' do
    assert @comment.valid?
  end

  test 'invalid without content' do
    @comment.content = nil
    refute @comment.valid?, 'comment is valid without a content'
    assert_not_nil @comment.errors[:content], 'no validation error for content present'
  end
end
