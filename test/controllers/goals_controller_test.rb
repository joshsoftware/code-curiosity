require "test_helper"

class GoalsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_response :success
  end

  def test_show
    get :show
    assert_response :success
  end

  def test_edit
    get :edit
    assert_response :success
  end

  def test_update
    get :update
    assert_response :success
  end

end
