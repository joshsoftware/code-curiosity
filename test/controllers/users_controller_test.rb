require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should return success when edit is called" do
    goal = create :goal, points: 15
    goal_2 = create :goal, points: 30
    round = create :round, :open
    user = create :user, auth_token: 'dah123rty', goal: goal
    sign_in user
    xhr :get, :edit, id: user.id
    assert_response :success
  end

  test "should update twitter handle when update" do
    goal = create :goal, points: 15
    goal_2 = create :goal, points: 30
    round = create :round, :open
    user = create :user, auth_token: 'dah123rty', goal: goal
    sign_in user
    xhr :patch, :update, user: { twitter_handle: 'amitk'}, id: user.id
    assert_response :success
    assert_equal '@amitk', user.reload.twitter_handle
  end
end
