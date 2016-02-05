require "test_helper"

class ActivitiesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_response :success
  end

end
