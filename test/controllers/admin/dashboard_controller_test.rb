require "test_helper"

class Admin::DashboardControllerTest < ActionController::TestCase

  test 'non logged-in user accesses index page' do
    setup_data
    get :index
    assert_response :redirect
  end

  test 'logged-in user accesses index page' do
    setup_data
    sign_in @user
    get :index
    assert_response :redirect
  end

  test 'admin user accesses index page' do
    setup_data
    @user.roles << @admin_role
    sign_in @user
    get :index
    assert_response :success
    assert_template :index
  end

  private

  def setup_data
    @admin_role = create :role, :admin
    @goal = create :goal, points: 15
    @round = create :round, :open
    @user = create :user, auth_token: 'dah123rty', goal: @goal
  end

end
