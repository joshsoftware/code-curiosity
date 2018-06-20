require "test_helper"

class RedeemRequestTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def redeem_request
    @redeem_request ||= build(:redeem_request)
  end

  test "validity of redeem_request" do
    user = create :user
    redeem_request = build(:redeem_request, :points => 2, :address => 'baner', user: user)
    assert_not redeem_request.valid?
  end

  test "address must be present when retailer is other" do
    redeem_request = build(:redeem_request, :points => 2, :retailer => 'other', :gift_product_url => Faker::Internet.url)
    redeem_request.valid?
    assert_not_empty redeem_request.errors[:address]
  end

  test "gift_product_url must be present when retailer category is other" do
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
    user = create :user
    transaction = create(:transaction, :points => 3, :type => 'credit', user: user)
    redeem_request = build(:redeem_request, :points => 2, :address => 'baner', user: user, transaction: transaction)
    redeem_request.update_transaction_points
    assert_equal redeem_request.transaction.points, 2
  end

  test "whether retailer category is other" do
    redeem_request = build(:redeem_request, :points => 2, :retailer => 'other', :gift_product_url => Faker::Internet.url, :address => 'baner')
    assert redeem_request.retailer_other?
  end

  test "user total points must be greater than or equal to redeemption points" do
    user = create(:user)
    transaction = create(:transaction, :points => 4, :type => 'credit', user: user)
    redeem_request = create(:redeem_request, :points => 3, :address => 'baner', :retailer => 'github', user: user)
    assert_empty redeem_request.errors[:points]
  end

  test "for redeemption points must be greater than zero" do
    user = create(:user)
    redeem_request = build(:redeem_request, :points => 0, :retailer => 'amazon', user: user)
    redeem_request.save
    assert_not_empty redeem_request.errors[:points]
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

  # test "user should not be able to redeem if redemption points is greater than 500 and user points is zero" do
  #   user = create :user
  #   round_1 = create :round, status: "open", from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month
  #   royalty_points = 1500
  #   royalty_transaction = create :transaction, points: royalty_points, transaction_type: 'royalty_bonus', type: 'credit', user: user
  #   round_transaction = create :transaction, points: 0, type: 'credit', transaction_type: 'Round', user: user
  #   redeem_request = build :redeem_request, points: 1000, user: user
  #   redeem_request.save
  #   assert_not_empty redeem_request.errors[:points]
  #   assert_equal 0, user.redeem_requests.count
  #   assert_equal 2, user.transactions.count
  # end

  test "should not redeem for others retailer if user total points is 0" do
    user = create :user
    round_transaction = create :transaction, points: 0, type: 'credit', user: user
    redeem_request_1 = build :redeem_request, points: 0, address: 'baner', retailer: 'other', gift_product_url: Faker::Internet.url, user: user
    redeem_request_1.valid?
    assert_not_empty redeem_request_1.errors[:gift_product_url]
    assert_equal redeem_request_1.errors[:gift_product_url].first, "insufficient balance. You have only $ 0 in your account."
  end

  # test "should set the amount" do
  #   user = create :user
  #   round_1 = create :round, status: "open", name: Date.today.beginning_of_month.strftime("%b %Y"), from_date: Date.today.beginning_of_month,
  #     end_date: Date.today.end_of_month
  #   subscription = create(:subscription, user: user, round: round_1)
  #   royalty_points = 1000
  #   royalty_transaction = create :transaction, points: royalty_points, transaction_type: 'royalty_bonus', type: 'credit', user: user
  #   round_transaction = create :transaction, points: 10, type: 'credit', user: user
  #
  #   redeem_request_1 = create :redeem_request, points: 100, user: user
  #   assert_equal 5, redeem_request_1.amount
  #
  #   sponsorer_detail = create :sponsorer_detail, user: user
  #   redeem_request_2 = create :redeem_request, points: 100, user: user, sponsorer_detail: sponsorer_detail
  #   assert_equal 10, redeem_request_2.reload.amount
  # end
end
