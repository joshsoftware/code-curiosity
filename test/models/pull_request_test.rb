require_relative "../test_helper"

class PullRequestTest < ActiveSupport::TestCase
  test "number must be present" do
    pull_request = build(:pull_request, number: '')
    pull_request.valid?
    assert_not_empty pull_request.errors[:number]
  end

  test "created_at_git must be present" do
    pull_request = build(:pull_request, created_at_git: '')
    pull_request.valid?
    assert_not_empty pull_request.errors[:created_at_git]
  end

  test "author_association must be present" do
    pull_request = build(:pull_request, author_association: '')
    pull_request.valid?
    assert_not_empty pull_request.errors[:author_association]
  end

  test "comment_count must be present" do
    pull_request = build(:pull_request, comment_count: '')
    pull_request.valid?
    assert_not_empty pull_request.errors[:comment_count]
  end
end
