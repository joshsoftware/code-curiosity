require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  before(:all) do
    @goal = create :goal
    @round = create :round, :open
    @user = create :user, auth_token: 'dah123rty', goal: @goal
  end

  test 'should get index for non logged-in user' do
    get :index
    assert_response :success
    assert_template :index
  end

  test 'should redirect to dashboard if logged-in user' do
    sign_in @user
    get :index
    assert_response :redirect
    assert_redirected_to dashboard_path
  end

  test 'should load featured_groups for non logged-in user' do
    get :index
    assert_response :success
    assert_template partial: '_trend'
  end

  test 'should get trends' do
    get :trend
    assert_response :success
    assert_template :trend
  end

  test 'should get trends for a goal' do
    get :trend, goal_id: @goal.id
    assert_response :success
    assert_template :trend
  end

end
