require "test_helper"

class RedeemControllerTest < ActionController::TestCase
  
  def test_controller_and_action_name
    seed_round_and_user
    xhr :post, :create, redeem_request: {:retailer => 'github', :points => 100}, :id => @user.id
    assert_equal "text/javascript", @response.content_type
    assert_equal "create", @controller.action_name
  end

  def test_redeem_request_not_created_if_points_is_0
    seed_round_and_user
    xhr :post, :create, redeem_request: {:retailer => 'github', :points => 0}, :id => @user.id
    assert_equal RedeemRequest.count, 0
  end

  def test_it_must_create_redeem_request_if_points_is_greater_than_zero
    seed_round_and_user
    xhr :post, :create, redeem_request: {:retailer => 'github', :points => 100}, :id => @user.id
    assert_equal RedeemRequest.count, 1
    assert_response :success
  end

  def test_redeem_request_when_retailer_is_github
    seed_round_and_user
    xhr :post, :create, redeem_request: {:retailer => 'github', :points => 121}, :id => @user.id
    assert_template  'redeem/_github'
  end

  def test_redeem_request_when_retailer_is_amazon
    seed_round_and_user
    xhr :post, :create, redeem_request: {:retailer => 'amazon', :points => 121}, :id => @user.id
    assert_template  'redeem/_amazon'
  end

  def test_redeem_request_when_retailer_is_others
    seed_round_and_user
    xhr :post, :create, redeem_request: {:retailer => 'other', :points => 121}, :id => @user.id
    assert_template  'redeem/_other'
  end

  def seed_round_and_user
    round = create(:round, :status => 'open')
    @user = create(:user, :auth_token => 'dah123rty', goal: create(:goal))
    sign_in @user
    royalty_transaction = create :transaction, points: 0, transaction_type: 'royalty_bonus', type: 'credit', user: @user
    transaction = create(:transaction, :type => 'credit', :points => 120, user: @user)
  end
    
end
