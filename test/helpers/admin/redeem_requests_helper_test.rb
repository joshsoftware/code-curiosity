require "test_helper"

class Admin::RedeemRequestsHelperTest < ActionView::TestCase

  test "check worth of points" do
    create_user
    redeem_request = create(:redeem_request,:points => 10, user: @user)
    assert_equal redeem_request.points/10, total_capital_of_points     
    assert_kind_of Fixnum, total_capital_of_points, "Must be a value"
  end

  def create_user
    round = create(:round, :status => 'open')
    role = create(:role, :name => 'Admin')
    @user = create(:user, goal: create(:goal))
    @user.roles << role
    transaction = create(:transaction, :type => 'credit', :points => 120, user: @user)
  end

end
