require "test_helper"

class Admin::RedeemRequestsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_response :success
  end

end
