require "test_helper"

class Admin::RedeemRequestsControllerTest < ActionController::TestCase 
 
  def test_must_get_users_redemption_requests
    seed_data
    xhr :get, :index, parameters, format: :js,  :id => @user.id
    assert_response :success
  end

  def test_should_not_update_redeem_request_without_any_parameter
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    assert_raises ActionController::ParameterMissing do 
      put :update, :id => redeem_request.id
    end
  end

  def test_must_update_redeem_requests_parameters
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    updated_coupon_code = 'josh24'
    patch :update, :id => redeem_request.id, redeem_request: {:coupon_code => updated_coupon_code}
    redeem_request.reload
    assert_equal updated_coupon_code, redeem_request.coupon_code 
    assert_response :redirect
  end

  def test_should_destroy_redeem_request 
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    assert_difference('RedeemRequest.count', -1) do
      delete :destroy, id: redeem_request.id
    end
    assert_response :redirect
  end

  def test_should_destroy_transaction_corresponding_to_redeem_request 
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    assert_difference('Transaction.count', -1) do
      delete :destroy, id: redeem_request.id
    end
    assert_response :redirect
  end

  def seed_data
    round = create(:round, :status => 'open')
    role = create(:role, :name => 'Admin')
    @user = create(:user, :auth_token => 'dah123rty', goal: create(:goal))
    @user.roles << role
    sign_in @user
    transaction = create(:transaction, :type => 'credit', :points => 120, user: @user)
  end

  def parameters
    {"redeem_request"=>{'coupon_code' => 'josh12' ,'points' => '100'}}
  end

end
