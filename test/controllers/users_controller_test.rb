require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    super
    @user = create :user, auth_token: 'dah123rty'
  end

  test 'destroy' do
    assert_equal @user.deleted?, false
    sign_in @user
    delete :destroy, { id: @user.id }
    @user.reload
    assert @user.deleted?
    assert @user.deleted_at.present?
    assert @user.auto_created
    assert_equal @user.active, false
  end

  test "only logged in user is abled to update his twitter handle" do
    user = create :user, auth_token: 'dah123rty'
    sign_in user
    xhr :get, :edit, id: user.id
    assert_response :success
  end

  test "must not update twitter handle if user is not logged in" do
    user = create :user, auth_token: 'aswq123ew'
    xhr :get, :edit, id: user.id
    assert_response 401
  end

  test "should update twitter handle when update" do
    user = create :user, auth_token: 'dah123rty'
    sign_in user
    xhr :patch, :update, user: { twitter_handle: 'amitk'}, id: user.id
    assert_response :success
    assert_equal '@amitk', user.reload.twitter_handle
  end
end
