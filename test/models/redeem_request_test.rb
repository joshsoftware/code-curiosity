require "test_helper"

class RedeemRequestTest < ActiveSupport::TestCase

  def redeem_request
    @redeem_request ||= build(:redeem_request)
  end

  def test_validity_of_redeem_request
  	redeem_request = build(:redeem_request, :points => 2, :address => 'baner')
    assert_not redeem_request.valid?
  end

  def test_address_must_be_present_when_retailer_is_other
    redeem_request = build(:redeem_request, :points => 2, :retailer => 'other', :gift_product_url => Faker::Internet.url)
    redeem_request.valid?
    assert_not_empty redeem_request.errors[:address]
  end

  def test_gift_produt_url_must_be_present_when_retailer_category_is_other
    redeem_request = build(:redeem_request, :points => 2, :retailer => 'other', :address => 'pune')
    redeem_request.valid?
    assert_not_empty redeem_request.errors[:gift_product_url]
  end

  def test_no_updation_of_transaction_points_when_point_is_zero
    transaction = create(:transaction, :points => 3, :type => 'credit')
    redeem_request = build(:redeem_request, :points => 0, :address => 'baner', transaction: transaction)
    redeem_request.update_transaction_points
    assert_equal redeem_request.transaction.points, 3
  end

  def test_update_transaction_points_only_when_points_greater_than_zero
    transaction = create(:transaction, :points => 3, :type => 'credit')
  	redeem_request = build(:redeem_request, :points => 2, :address => 'baner', transaction: transaction)
  	redeem_request.update_transaction_points
    assert_equal redeem_request.transaction.points, 2
  end

  def test_whether_retailer_category_is_other
  	redeem_request = build(:redeem_request, :points => 2, :address => 'baner', :retailer => 'other', :gift_product_url => Faker::Internet.url, :address => 'baner')
  	assert redeem_request.retailer_other?
  end

  def test_user_total_points_must_be_greater_than_or_equal_to_redeemption_points
    user = create(:user)
    transaction = create(:transaction, :points => 4, :type => 'credit', user: user)
    redeem_request = create(:redeem_request, :points => 3, :address => 'baner', :retailer => 'github', user: user)
    assert_empty redeem_request.errors[:points]
  end

  def test_for_redeemption_points_must_be_greater_than_zero
    redeem_request = build(:redeem_request, :points => 0, :retailer => 'amazon', user: create(:user_with_transactions))
    redeem_request.save
    assert_not_empty redeem_request.errors[:points]
  end

  def test_points_not_in_mutiple_of_hundred_so_no_redeemption
    redeem_request = build(:redeem_request, :points => 2, :retailer => 'amazon', user: create(:user_with_transactions))
    redeem_request.save
    assert_not_empty redeem_request.errors[:points]
  end

  def test_points_must_be_in_multiple_of_hundred_for_redeemption
    user = create(:user)
    transaction = create(:transaction, :points => 100, :type => 'credit', user: user)
    redeem_request = create(:redeem_request, :points => 2, user: user)
    assert redeem_request.valid?
  end

  def test_creating_redeem_request_must_create_redeem_transaction
    user = create(:user, :points => 3)
    transaction = create(:transaction, :type => 'credit', :points => 5, user: user)
    redeem_request = create(:redeem_request, :points => 2, user: user)
    transaction_type = redeem_request.transaction.transaction_type
    assert_equal transaction_type, 'redeem_points'
  end 
 
end
