require "test_helper"

class Admin::RedeemRequestsHelperTest < ActionView::TestCase

  test "check worth of points" do
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    total_capital = redeem_request.points/10
    assert_equal total_capital, total_capital_of_points
  end

  def seed_data
    round = create(:round, :status => 'open')
    role = create(:role, :name => 'Admin')
    @user = create(:user, goal: create(:goal))
    @user.roles << role
    transaction = create(:transaction, :type => 'credit', :points => 120, user: @user)
  end

end
