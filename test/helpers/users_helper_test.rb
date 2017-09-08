require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  test "show remove twitter handle prefix from twitter handle" do
    twitter_handle = "@amitk301293"
    assert_equal = "amitk301293", remove_prefix(twitter_handle)
  end
end