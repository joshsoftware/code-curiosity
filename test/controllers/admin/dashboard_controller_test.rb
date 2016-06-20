require "test_helper"

class Admin::DashboardControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_response :success
  end

end
