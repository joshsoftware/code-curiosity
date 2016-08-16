require "test_helper"

class TransactionTest < ActiveSupport::TestCase
 
  def test_transaction_type_must_be_present
    transaction = build(:transaction, :type => nil)
    transaction.valid?
    assert_not_empty transaction.errors[:type]
  end

  def test_points_must_be_present 
    transaction = build(:transaction, :points => nil)
    transaction.valid?
    assert_not_empty transaction.errors[:points]
  end

   def test_type_should_be_either_credit_or_debit
    transaction = build(:transaction, :type => Faker::Lorem.words)
    transaction.valid?
    assert_not_includes(['credit','debit'],transaction.type)
  end

  def test_transaction_should_be_credit
    transaction = build(:transaction, :type => 'debit')
    assert_not transaction.credit?
  end

  def test_during_redeem_transaction_transaction_type_should_be_redeem_points
    transaction = build(:transaction, :transaction_type => 'redeem_points')
    assert transaction.redeem_transaction?
  end

  def test_update_user_total_points_after_transaction_is_created
    transaction = build(:transaction, :type => 'credit', :points => 2)
    transaction.user.points = 3
    transaction.save
    assert_equal transaction.user.points, 5
  end

  def test_update_only_when_points_greater_than_zero 
    transaction = build(:transaction,:points => 2, :type => 'credit', user: FactoryGirl.create(:user))
    transaction.user.points = 1
    transaction.update_user_total_points
    assert_equal(transaction.user.points, 3)
  end

  def test_no_updation_when_points_equal_to_zero
    transaction = build(:transaction, :points => 0, :type => 'credit')
    transaction.user.points = 1
    transaction.update_user_total_points
    assert_equal(transaction.user.points, 1)
  end

  
  def test_check_total_points_before_redemption
    transaction = FactoryGirl.create_list(:transaction, 3, :type => 'credit', :transaction_type => 'Round', :points => 1)
    transaction = Transaction.where(:transaction_type.in => ['Round','royalty_bonus'])
    sum = transaction.inject(0){|sum,t| sum + t.points}
    assert_equal(Transaction.total_points_before_redemption, sum)
  end

  def test_check_total_points_before_redemption_in_case_of_royalty_bonus
    transaction = create_list(:transaction, 2, :points => 1, :type => 'credit', :transaction_type => 'royalty_bonus')
    transaction = Transaction.where(:transaction_type => 'royalty_bonus')
    trans = Transaction.where(:transaction_type => 'Round')
    sum = transaction.inject(0){|sum,t| sum + t.points}
    royalty_bonus = Transaction.total_points_before_redemption-(trans.sum(:points))
    assert_equal(royalty_bonus,sum)
  end

  def test_check_total_points_reedemed
    transaction = FactoryGirl.create_list(:transaction, 3, :type => 'credit', :points => 1, transaction_type: 'redeem_points')
    transaction = Transaction.where(:transaction_type => 'redeem_points')
    sum = transaction.inject(0){|sum,t| sum + t.points }
    assert_equal(Transaction.total_points_redeemed,sum.abs)
  end

  def test_coupon_code_exist_if_transaction_is_redeem_points
    transaction = create(:transaction, :points => 1, :type => 'credit', :transaction_type => 'redeem_points')
    redeem_request = build(:redeem_request, :points => 2, :retailer => 'other', :address => 'pune', :gift_product_url => Faker::Internet.url, :coupon_code => 'aitpune')
    transaction.redeem_request = redeem_request
    assert_not_nil transaction.coupon_code
  end

end
