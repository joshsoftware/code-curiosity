require "test_helper"

class Admin::RedeemRequestsHelperTest < ActionView::TestCase

  test "check worth of points" do
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    total_capital = redeem_request.points/REDEEM['one_dollar_to_points']
    assert_equal total_capital, total_capital_of_points
  end

  test "check value of points if store is amazon.in" do
    seed_data
    create(:redeem_request, points: 50, user: @user, store: 'amazon.in')
    create(:redeem_request, points: 50, user: @user, store: 'amazon.uk')
    assert_equal RedeemRequest.where(store: 'amazon.in').sum(:points)/REDEEM['one_dollar_to_points'], capital_by_store('amazon.in')
  end

  test "check value of points if store is amazon.com" do
    seed_data
    create(:redeem_request, points: 20, user: @user, store: 'amazon.in')
    create(:redeem_request, points: 10, user: @user, store: 'amazon.uk')
    assert_equal capital_by_store('amazon.com'), RedeemRequest.where(store: 'amazon.com').sum(:points)/REDEEM['one_dollar_to_points']
  end

  test "check value of points if store is amazon.uk" do
    seed_data
    create(:redeem_request, points: 80, user: @user, store: 'amazon.in')
    create(:redeem_request, points: 50, user: @user, store: 'amazon.uk')
    assert_equal capital_by_store('amazon.uk'), RedeemRequest.where(store: 'amazon.uk').sum(:points)/REDEEM['one_dollar_to_points']
  end

  def seed_data
    round = create(:round, :status => 'open')
    role = create(:role, :name => 'Admin')
    @user = create(:user, goal: create(:goal))
    @user.roles << role
    transaction = create(:transaction, :type => 'credit', :points => 120, user: @user)
  end

end
