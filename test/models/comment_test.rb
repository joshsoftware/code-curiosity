require "test_helper"

class CommentTest < ActiveSupport::TestCase

  def test_content_should_be_present
    comment = build(:comment, :content => nil)
    comment.valid?
    assert_not_empty comment.errors[:content]
  end

  def test_commemt_count_should_be_zero_before_creating_any_comment
    comment = build(:comment, :content => Faker::Lorem.sentences)
    commit = build(:commit)
    comment.commentable = commit
    comments_count = comment.commentable.comments_count
    assert_equal comments_count, 0
  end

  def test_comment_count_should_be_incremented_after_creating_comment
    comment = build(:comment, :content => Faker::Lorem.sentences)
    commit = build(:commit)
    comment.commentable = commit
    comment.save
    comments_count = comment.commentable.comments_count
    assert_equal comments_count, 1
  end

end
