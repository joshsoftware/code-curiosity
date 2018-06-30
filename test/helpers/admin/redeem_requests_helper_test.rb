require "test_helper"

class Admin::RedeemRequestsHelperTest < ActionView::TestCase

  test "check value of points if store is not provided" do
    seed_data
    create(:redeem_request, points: 100, user: @user)
    create(:redeem_request, points: 100, user: @user, store: 'amazon.in')
    create(:redeem_request, points: 100, user: @user, store: 'amazon.uk')
    assert_equal 300, amount_for_store
  end

  test "check value of points if store is provided" do
    seed_data
    create(:redeem_request, points: 100, user: @user)
    create(:redeem_request, points: 100, user: @user, store: 'amazon.in')
    create(:redeem_request, points: 100, user: @user, store: 'amazon.uk')
    assert_equal 100, amount_for_store('amazon.in')
  end

  def seed_data
    role = create(:role, :name => 'Admin')
    @user = create(:user)
    @user.roles << role
    transaction = create(:transaction, :type => 'credit', :points => 420, user: @user)
  end

end
