require "test_helper"

class Admin::RepositoriesHelperTest < ActionView::TestCase

  test "should return true of string true and vice versa" do
    assert_equal check_boolean("true"), true
    assert_equal check_boolean("false"), false
  end
  
  # def test_sanity
  #   flunk "Need real tests"
  # end
end
