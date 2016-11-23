require "test_helper"

class Admin::UsersControllerTest < ActionController::TestCase

  def setup
    super
    @admin_role = create :role, :admin
    @goal = create :goal, points: 15
    @round = create :round, :open
    @user = create :user, auth_token: 'dah123rty', goal: @goal
  end

  test 'should not access index if the current user is non-admin' do
    sign_in @user
    get :index
    assert_response :redirect
  end

  test 'should access users index only if the user is admin' do
    @user.roles << @admin_role
    sign_in @user
    other_user = create :user, auth_token: Faker::Lorem.word, goal: @goal
    assert_equal User.count, 2
    get :index
    assert_response :success
  end

  test 'should destroy all associations of the user on destroying any user by admin' do
    @user.roles << @admin_role
    sign_in @user
    other_user = create :user, auth_token: 'dah123rty', goal: @goal
    royalty_transaction = create :transaction, points: 0, transaction_type: 'royalty_bonus', type: 'credit', user: other_user
    assert_equal other_user.transactions.count, 1
    transaction = create_list :transaction, 3, type: 'credit', user: other_user
    assert_equal other_user.transactions.count, 4
    redeem_request = create :redeem_request, points: 2, user: other_user
    assert_equal other_user.transactions.count, 5
    delete :destroy, id: other_user.id
    assert_equal Transaction.count, 0
    assert_equal RedeemRequest.count, 0
    assert_response :redirect
  end

end
