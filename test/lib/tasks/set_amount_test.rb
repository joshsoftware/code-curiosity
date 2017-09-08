require 'test_helper'

class SetAmountTest < ActiveSupport::TestCase
  def setup
    @user = create :user
    CodeCuriosity::Application.load_tasks
    Rake::Task['set_amount:set_amount_for_transactions'].reenable
  end

  test "set transaction amount $1:10 points when transaction before 2nd August 2017 and transaction type is redeem points" do
    transaction = create :transaction, transaction_type: 'redeem_points', type: 'debit', created_at: DateTime.parse("11/04/2017"), points: 200, user: @user
    run_rake_task
    assert_equal -20, transaction.reload.amount
  end

  test "set transaction amount $1:10 points when transaction before 2nd August 2017 and transaction type is round points" do
    transaction = create :transaction, transaction_type: 'Round', type: 'credit', created_at: DateTime.parse("12/02/2017"), points: 50, user: @user
    run_rake_task
    assert_equal 5, transaction.reload.amount
  end

  test "set transaction amount $1:10 points when transaction before 2nd August 2017 and transaction type is royalty bonus" do
    transaction = create :transaction, transaction_type: 'royalty_bonus', type: 'credit', created_at: DateTime.parse("13/07/2017"), points: 300, user: @user
    run_rake_task
    assert_equal 30, transaction.reload.amount
  end

  test "set transaction amount $1:10 points when transaction before 2nd August 2017 and transaction type is goal bonus" do
    transaction = create :transaction, transaction_type: 'GoalBonus', type: 'credit', created_at: DateTime.parse("11/07/2017"), points: 20, user: @user
    run_rake_task
    assert_equal 2, transaction.reload.amount
  end

  test "set transaction amount $1:20 points when transaction on or after 2nd August 2017 and transaction type is round points and user on free plan" do
    user = create :user, is_sponsorer: false
    transaction = create :transaction, transaction_type: 'Round', type: 'credit', created_at: DateTime.parse("11/08/2017"), points: 20, user: user
    run_rake_task
    assert_equal 1, transaction.reload.amount
  end

  test "set transaction amount $1:20 points when transaction on or after 2nd August 2017 and transaction type is goal bonus and user on free plan" do
    user = create :user, is_sponsorer: false
    transaction = create :transaction, transaction_type: 'GoalBonus', type: 'credit', created_at: DateTime.parse("11/08/2017"), points: 250, user: user
    run_rake_task
    assert_equal 12.5, transaction.reload.amount
  end

  test "set transaction amount $1:20 points when transaction on or after 2nd August 2017 and transaction type is redeem points and user on free plan" do
    user = create :user, is_sponsorer: false
    transaction = create :transaction, transaction_type: 'redeem_points', type: 'debit', created_at: DateTime.parse("11/08/2017"), points: 200, user: user
    run_rake_task
    assert_equal -10, transaction.reload.amount
  end

  test "set transaction amount $1:10 points when transaction on or after 2nd August 2017 and transaction type is redeem points and user on paid plan" do
    user = create :user, is_sponsorer: true
    sponsorer_detail = create :sponsorer_detail, user: user
    transaction = create :transaction, transaction_type: 'redeem_points', type: 'debit', created_at: DateTime.parse("11/08/2017"), points: 200, user: user
    run_rake_task
    assert_equal -20, transaction.reload.amount
  end

  test "set transaction amount $1:10 points when transaction on or after 2nd August 2017 and transaction type is Round points and user on paid plan" do
    user = create :user, is_sponsorer: true
    sponsorer_detail = create :sponsorer_detail, user: user
    transaction = create :transaction, transaction_type: 'Round', type: 'credit', created_at: DateTime.parse("11/08/2017"), points: 200, user: user
    run_rake_task
    assert_equal 20, transaction.reload.amount
  end

  test "set transaction amount $1:10 points when transaction on or after 2nd August 2017 and transaction type is goal bonus and user on paid plan" do
    user = create :user, is_sponsorer: true
    sponsorer_detail = create :sponsorer_detail, user: user
    transaction = create :transaction, transaction_type: 'GoalBonus', type: 'credit', created_at: DateTime.parse("11/08/2017"), points: 250, user: user
    run_rake_task
    assert_equal 25, transaction.reload.amount
  end

  test "set transaction amount $1:10 points when transaction is on or after 2nd August 2017 and transaction type is royalty points and user took subscription within a month after sign up" do
    user = create :user, is_sponsorer: true, created_at: DateTime.parse("3/08/2017")
    sponsorer_detail = create :sponsorer_detail, created_at: DateTime.parse("5/08/2017"), user: user
    transaction = create :transaction, transaction_type: 'royalty_bonus', type: 'credit',
      created_at: DateTime.parse("3/08/2017"), points: 500, user: user
    run_rake_task
    assert_equal 50, transaction.reload.amount
  end

  test "set transaction amount $1:20 points when transaction is on or after 2nd August 2017 and transaction type is royalty points and user signed up and took subscription after 1 month" do
    user = create :user, is_sponsorer: true, created_at: DateTime.parse("3/08/2017")
    sponsorer_detail = create :sponsorer_detail, created_at: DateTime.parse("5/09/2017"), user: user
    transaction = create :transaction, transaction_type: 'royalty_bonus', type: 'credit',
      created_at: DateTime.parse("3/08/2017"), points: 500, user: user
    run_rake_task
    assert_equal 25, transaction.reload.amount
  end

  test "set transaction amount $1:20 points when transaction is between 1st August and 2nd August 2017 and transaction type is redeem points" do
    transaction = create :transaction, transaction_type: 'redeem_points', type: 'debit', created_at: DateTime.parse("1/08/2017 08:30"), points: 500, user: @user
    run_rake_task
    assert_equal -25, transaction.reload.amount
  end

  private

  def run_rake_task
    Rake::Task['set_amount:set_amount_for_transactions'].invoke
  end
end
