require "test_helper"

class TransactionSerializerTest < ActiveSupport::TestCase
  def setup
    super
    @redeem_request = create(:redeem_request, points: 50, retailer: 'other', address: 'pune', gift_product_url: Faker::Internet.url,
                            coupon_code: 'aitpune')
    @transaction = create(:transaction, transaction_type: 'redeem_points', type: :debit, redeem_request: @redeem_request, points: -50)
  end

  test 'serialize the transaction' do
    serializer = TransactionSerializer.new(@transaction)
    data = serializer.serializable_hash

    assert_equal @transaction.id, data[:id]
    assert_equal -50, data[:points]
    assert_equal 'debit', data[:type]
    assert_equal 'Redeem points', data[:transaction_type]
    assert_equal 'aitpune', data[:coupon_code]
    assert_equal 'other', data[:redeem_request_retailer]
    assert_equal @transaction.created_at.strftime('%d/%b/%Y %T'), data[:created_at]
  end

end
