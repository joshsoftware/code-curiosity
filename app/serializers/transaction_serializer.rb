class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :points, :type, :transaction_type, :description, :created_at, :coupon_code, :redeem_request_retailer, :amount

  def transaction_type
    object.transaction_type.humanize
  end

  def created_at
    object.created_at.strftime('%d/%b/%Y %T')
  end

  def redeem_request_retailer
    object.redeem_request.retailer if object.redeem_request?
  end
end
