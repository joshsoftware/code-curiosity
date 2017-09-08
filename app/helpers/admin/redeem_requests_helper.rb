module Admin::RedeemRequestsHelper

  def amount_for_store(store = nil)
    redeem_requests = RedeemRequest.where(status: false)
    redeem_requests = redeem_requests.where(store: store) if store and REDEEM['amazon_stores'].include?(store)
    redeem_requests.sum(:amount)
  end

end
