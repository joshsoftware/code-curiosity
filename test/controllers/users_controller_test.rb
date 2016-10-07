require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    super
    @goal = create :goal
    @round = create :round, :open
    @user = create :user, auth_token: 'dah123rty', goal: @goal
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
end
