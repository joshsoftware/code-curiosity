module Admin::RedeemRequestsHelper

  def total_capital_of_points
    RedeemRequest.total_points_redeemed/10
  end
  
end
