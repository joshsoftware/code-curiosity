require "test_helper"

class Admin::IgnoredFilesControllerTest < ActionController::TestCase
  def test_index
    skip "need test_cases"
    get :index
    assert_response :success
  end
end
