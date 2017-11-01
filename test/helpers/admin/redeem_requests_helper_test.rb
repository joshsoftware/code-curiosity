require "test_helper"

class Admin::RedeemRequestsHelperTest < ActionView::TestCase

  test "check value of points if store is not provided and redeem requester isnt an sponsorer" do
    seed_data
    create(:redeem_request, points: 100, user: @user, sponsorer_detail: nil)
    create(:redeem_request, points: 100, user: @user, store: 'amazon.in', sponsorer_detail: nil)
    create(:redeem_request, points: 100, user: @user, store: 'amazon.uk', sponsorer_detail: nil)
    assert_equal 15, amount_for_store
  end

  test "check value of points if store is not provided and redeem requester an sponsorer" do
    seed_data
    sponsorer_detail = create :sponsorer_detail, user: @user
    create(:redeem_request, points: 100, user: @user, sponsorer_detail: sponsorer_detail)
    create(:redeem_request, points: 100, user: @user, store: 'amazon.in', sponsorer_detail: sponsorer_detail)
    create(:redeem_request, points: 100, user: @user, store: 'amazon.uk', sponsorer_detail: sponsorer_detail)
    assert_equal 30, amount_for_store
  end

  test "check value of points if store is provided and redeem requester isnt an sponsorer" do
    seed_data
    create(:redeem_request, points: 100, user: @user, sponsorer_detail: nil)
    create(:redeem_request, points: 100, user: @user, store: 'amazon.in', sponsorer_detail: nil)
    create(:redeem_request, points: 100, user: @user, store: 'amazon.uk', sponsorer_detail: nil)
    assert_equal 5, amount_for_store('amazon.in')
  end

  test "check value of points if store is provided and redeem requester an sponsorer" do
    seed_data
    sponsorer_detail = create :sponsorer_detail, user: @user
    create(:redeem_request, points: 100, user: @user, sponsorer_detail: sponsorer_detail)
    create(:redeem_request, points: 100, user: @user, store: 'amazon.in', sponsorer_detail: sponsorer_detail)
    create(:redeem_request, points: 100, user: @user, store: 'amazon.uk', sponsorer_detail: sponsorer_detail)
    assert_equal 10, amount_for_store('amazon.in')
  end

  def seed_data
    round = create(:round, :status => 'open')
    role = create(:role, :name => 'Admin')
    @user = create(:user, goal: create(:goal))
    @user.roles << role
    transaction = create(:transaction, :type => 'credit', :points => 420, user: @user)
  end

end
