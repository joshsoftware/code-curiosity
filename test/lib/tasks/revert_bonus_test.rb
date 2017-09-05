require 'test_helper'

class RevertBonusTest < ActiveSupport::TestCase
  def setup
    @user = create :user
    CodeCuriosity::Application.load_tasks
    Rake::Task['revert_bonus:revert_subscription_royalty_bonus'].reenable
  end

  test 'remove transaction which are created when user becomes a sponsorer' do
    sponsorer_detail = create :sponsorer_detail, user: @user
    transaction_1 = create :transaction, type: 'credit', transaction_type: 'royalty_bonus', points: 500, created_at: DateTime.parse("30/07/2017"), user: @user
    transaction_2 = create :transaction, type: 'credit', transaction_type: 'Round', points: 50, user: @user
    sponsorer_detail.save_payment_details('INDIVIDUAL', 250, Time.now)
    transaction_3 = create :transaction, type: 'credit', transaction_type: 'royalty_bonus', points: 550, user: @user
    transaction_4 = create :transaction, type: 'debit', transaction_type: 'redeem_points', points: -550, user: @user
    assert_equal 4, @user.transactions.count
    assert_equal 2, @user.transactions.where(transaction_type: 'royalty_bonus').count
    assert_equal 1, @user.transactions.where(transaction_type: 'redeem_points').count
    run_rake_task
    assert_equal 2, @user.transactions.count
    assert_equal 1, @user.transactions.where(type: 'credit', transaction_type: 'royalty_bonus', points: 500).count
    assert_equal 0, @user.transactions.where(type: 'debit', transaction_type: 'redeeem_points').count
  end

  test 'must not remove any other transactions' do
    transaction_1 = create :transaction, transaction_type: 'royalty_bonus', type: 'credit', points: 200, user: @user
    transaction_2 = create :transaction, transaction_type: 'redeem_points', type: 'debit', points: -100, user: @user
    assert_equal 2, @user.transactions.count
    assert_equal 1, @user.transactions.where(transaction_type: 'royalty_bonus').count
    assert_equal 1, @user.transactions.where(transaction_type: 'redeem_points').count
    run_rake_task
    assert_equal 2, @user.transactions.count
    assert_equal 1, @user.transactions.where(transaction_type: 'royalty_bonus').count
    assert_equal 1, @user.transactions.where(transaction_type: 'redeem_points').count
  end

  def run_rake_task
    Rake::Task['revert_bonus:revert_subscription_royalty_bonus'].invoke
  end
end
