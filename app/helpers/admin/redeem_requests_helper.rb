module Admin::RedeemRequestsHelper

  def amount_for_store(store = nil)
    redeem_requests = RedeemRequest.where(status: false)
    redeem_requests = redeem_requests.where(store: store) if store and REDEEM['amazon_stores'].include?(store)
    redeem_requests.sum(:amount)
  end

  def stores
  	stores = REDEEM['amazon_stores'].map { |store| ["#{store} #{amount_for_store(store)}", store] }
  	stores.unshift(['All'])
	end

	def users
		[['Free', false], ['Paid', true]]
	end

	def status
		[['Status Open', false], ['Status Closed', true]]
	end
end
