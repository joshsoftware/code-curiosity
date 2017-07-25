module Admin::RedeemRequestsHelper

  def total_capital_of_points
    RedeemRequest.where(status: false).sum(:points)/REDEEM['one_dollar_to_points']
  end
  
end
