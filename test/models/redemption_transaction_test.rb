require "test_helper"

class RedemptionTransactionTest < ActiveSupport::TestCase

  test "user have only round points" do
    user = create :user
    round_1 = create :round, status: "open", from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month
    
    round_transaction = create :transaction, points: 400, type: 'credit', transaction_type: 'Round', user: user

    redeem_request_1 = create :redeem_request, points: 100, user: user
    assert_equal  100, redeem_request_1.transaction.redemption_transaction.round_points
    assert_equal  0, redeem_request_1.transaction.redemption_transaction.royalty_points
    user.instance_variable_set(:@_t_p, nil)
    
    redeem_request_2 = create :redeem_request, points: 100, user: user
    assert_equal  100, redeem_request_2.transaction.redemption_transaction.round_points
    assert_equal  0, redeem_request_2.transaction.redemption_transaction.royalty_points
    user.instance_variable_set(:@_t_p, nil)
    
    assert_equal 2, RedemptionTransaction.count
    Round.destroy_all
    round_2 = create :round, status: "open", name: Date.today.next_month.beginning_of_month.strftime("%b %Y"), from_date: Date.today.next_month.beginning_of_month, end_date: Date.today.next_month.end_of_month
    redeem_request_2 = create :redeem_request, points: 200, user: user
  end

  test "user have only royalty points" do
    user = create :user
    round_1 = create :round, status: "open", from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month
    royalty_points = 200

    royalty_transaction = create :transaction, points: royalty_points, transaction_type: 'royalty_bonus', type: 'credit', user: user
    
    round_transaction = create :transaction, points: 0, type: 'credit', transaction_type: 'Round', user: user

    redeem_request_1 = create :redeem_request, points: 100, user: user
    assert_equal 100, redeem_request_1.transaction.redemption_transaction.royalty_points
    assert_equal 0, redeem_request_1.transaction.redemption_transaction.round_points
  end

  test "user have both royalty bonus as well as round points" do
    user = create :user
    round_1 = create :round, status: "open", name: Date.today.beginning_of_month.strftime("%b %Y"), from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month
    royalty_points = 200
    royalty_transaction = create :transaction, points: royalty_points, transaction_type: 'royalty_bonus', type: 'credit', user: user
    
    round_transaction = create :transaction, points: 200, type: 'credit', transaction_type: 'Round', user: user

    redeem_request_1 = create :redeem_request, points: 100, user: user
    assert_equal  100, redeem_request_1.transaction.redemption_transaction.round_points
    assert_equal Date.today.beginning_of_month.strftime("%b %Y"), redeem_request_1.transaction.redemption_transaction.round_name
    user.instance_variable_set(:@_t_p, nil)
    
    redeem_request_2 = create :redeem_request, points: 100, user: user
    assert_equal  100, redeem_request_2.transaction.redemption_transaction.round_points
    assert_equal  0, redeem_request_2.transaction.redemption_transaction.royalty_points
    user.instance_variable_set(:@_t_p, nil)
    
    redeem_request_3 = create :redeem_request, points: 100, user: user
    assert_equal  100, redeem_request_3.transaction.redemption_transaction.royalty_points
  end

  test "user have royalty bonus as well as round points and redeems few in current month and remaining in next month" do
    user = create :user
    round_1 = create :round, status: "open", name: Date.today.beginning_of_month.strftime("%b %Y"), from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month
    royalty_points = 700
    royalty_transaction = create :transaction, points: royalty_points, transaction_type: 'royalty_bonus', type: 'credit', user: user
    
    round_transaction = create :transaction, points: 200, type: 'credit', transaction_type: 'Round', user: user

    redeem_request_1 = create :redeem_request, points: 300, user: user
    assert_equal  200, redeem_request_1.transaction.redemption_transaction.round_points
    assert_equal  100, redeem_request_1.transaction.redemption_transaction.royalty_points
    assert_equal Date.today.beginning_of_month.strftime("%b %Y"), redeem_request_1.transaction.redemption_transaction.round_name
    user.instance_variable_set(:@_t_p, nil)
    
    redeem_request_2 = create :redeem_request, points: 100, user: user
    assert_equal  0, redeem_request_2.transaction.redemption_transaction.round_points
    assert_equal  100, redeem_request_2.transaction.redemption_transaction.royalty_points
    user.instance_variable_set(:@_t_p, nil)

    Round.destroy_all
    round_2 = create :round, status: "open", name: Date.today.next_month.beginning_of_month.strftime("%b %Y"), from_date: Date.today.next_month.beginning_of_month, end_date: Date.today.next_month.end_of_month
    redeem_request_1 = create :redeem_request, points: 300, user: user
    assert_equal  300, redeem_request_1.transaction.redemption_transaction.royalty_points
    assert_equal  0, redeem_request_1.transaction.redemption_transaction.round_points
    assert_equal Date.today.next_month.beginning_of_month.strftime("%b %Y"), redeem_request_1.transaction.redemption_transaction.round_name
  end
end
