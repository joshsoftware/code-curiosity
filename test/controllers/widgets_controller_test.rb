require "test_helper"

class WidgetsControllerTest < ActionController::TestCase
  def test_repo
    get :repo
    assert_response :success
  end

end
