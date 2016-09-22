require "test_helper"

class Admin::DashboardControllerTest < ActionController::TestCase
  def test_index
    admin_role = create :role, :admin
    goal = create :goal, points: 15
    round = create :round, :open
    user = create :user, auth_token: 'dah123rty', goal: goal
    user.roles << admin_role
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

end
