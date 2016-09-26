require "test_helper"

class GoalsControllerTest < ActionController::TestCase
  test 'index' do
    goal = create :goal, points: 15
    goal_2 = create :goal, points: 30
    round = create :round, :open
    user = create :user, auth_token: 'dah123rty', goal: goal
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_path
    sign_in user
    get :index
    assert_response :success
    assert_template :index
    assert assigns(:goals), 2
    assert assigns(:goals).first.points, 15
  end

  test 'show' do
    skip 'Method not defined'
    get :show
    assert_response :success
  end

  test 'edit' do
    skip 'Method not defined'
    get :edit
    assert_response :success
  end

  test 'update' do
    skip 'Method not defined'
    get :update
    assert_response :success
  end

end
