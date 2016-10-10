require "test_helper"

class RedeemRequestTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def redeem_request
    @redeem_request ||= build(:redeem_request)
  end

  test "validity of redeem_request" do
    redeem_request = build(:redeem_request, :points => 2, :address => 'baner')
    assert_not redeem_request.valid?
  end

  test "address must be present when retailer is other" do
    redeem_request = build(:redeem_request, :points => 2, :retailer => 'other', :gift_product_url => Faker::Internet.url)
    redeem_request.valid?
    assert_not_empty redeem_request.errors[:address]
  end

  test "gift_produt_url must be present when retailer category is other" do
    redeem_request = build(:redeem_request, :points => 2, :retailer => 'other', :address => 'pune')
    redeem_request.valid?
    assert_not_empty redeem_request.errors[:gift_product_url]
  end

  test "no updation of transaction points when point is zero" do
    transaction = create(:transaction, :points => 3, :type => 'credit')
    redeem_request = build(:redeem_request, :points => 0, :address => 'baner', transaction: transaction)
    redeem_request.update_transaction_points
    assert_equal redeem_request.transaction.points, 3
  end

  test "update transaction points only when points greater than zero" do
    transaction = create(:transaction, :points => 3, :type => 'credit')
    redeem_request = build(:redeem_request, :points => 2, :address => 'baner', transaction: transaction)
    redeem_request.update_transaction_points
    assert_equal redeem_request.transaction.points, 2
  end

  test "whether retailer category is other" do
    redeem_request = build(:redeem_request, :points => 2, :address => 'baner', :retailer => 'other', :gift_product_url => Faker::Internet.url)
    assert redeem_request.retailer_other?
  end

  test "user total points must be greater than or equal to redeemption points" do
    user = create(:user)
    transaction = create(:transaction, :points => 4, :type => 'credit', user: user)
    redeem_request = create(:redeem_request, :points => 3, :address => 'baner', :retailer => 'github', user: user)
    assert_empty redeem_request.errors[:points]
  end

  test "for redeemption points must be greater than zero" do
    redeem_request = build(:redeem_request, :points => 0, :retailer => 'amazon', user: create(:user_with_transactions))
    redeem_request.save
    assert_not_empty redeem_request.errors[:points]
  end

  test "points not in mutiple of hundred so no redeemption" do
    redeem_request = build(:redeem_request, :points => 2, :retailer => 'amazon', user: create(:user_with_transactions))
    redeem_request.save
    assert_not_empty redeem_request.errors[:points]
  end

  test "points must be in multiple of hundred for redeemption" do
    user = create(:user)
    transaction = create(:transaction, :points => 100, :type => 'credit', user: user)
    redeem_request = create(:redeem_request, :points => 2, user: user)
    assert redeem_request.valid?
  end

  test "creating redeem_request must create redeem_transaction" do
    user = create(:user, :points => 3)
    transaction = create(:transaction, :type => 'credit', :points => 5, user: user)
    redeem_request = create(:redeem_request, :points => 2, user: user)
    transaction_type = redeem_request.transaction.transaction_type
    assert_equal transaction_type, 'redeem_points'
  end

  test "transaction corresponding to redeem request must be destroyed when it is deleted" do
    user = create(:user)
    assert_equal user.transactions.count, 0
    transaction = create(:transaction, :type => 'credit', :points => 4, user: user)
    assert_equal user.transactions.count, 1
    redeem_request = create(:redeem_request, :points => 1, user: user)
    assert_equal user.redeem_requests.count, 1
    assert_equal user.transactions.count, 2
    redeem_request.destroy
    assert_equal user.redeem_requests.count, 0
    assert_equal user.transactions.count, 1
  end

  test "send notification only when coupon_code or comment is changed" do
    user = create(:user)
    assert_equal user.transactions.count, 0
    transaction = create(:transaction, :type => 'credit', :points => 4, user: user)
    assert_equal user.transactions.count, 1
    assert_enqueued_jobs 3 do
      redeem_request = create(:redeem_request, :points => 1, :coupon_code => 'abc', user: user)
    end
  end

  test "redeem request must be updated when coupon_code or comment_changed" do
    user = create(:user)
    assert_equal user.transactions.count, 0
    transaction = create(:transaction, :type => 'credit', :points => 4, user: user)
    assert_equal user.transactions.count, 1
    redeem_request = create(:redeem_request, :points => 1, user: user)
    assert_equal user.transactions.count, 2
    redeem_request.coupon_code = 'Josh12'
    redeem_request.save!
    assert_equal redeem_request.coupon_code, 'Josh12'
  end

end
