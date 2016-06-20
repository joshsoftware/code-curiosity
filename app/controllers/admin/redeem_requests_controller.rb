class Admin::RedeemRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @redeem_requests = RedeemRequest.desc(:created_at).page(params[:page])
  end

  def update
    @redeem_request = RedeemRequest.find(params[:id])
    if @redeem_request
      @redeem_request.update_attributes(redeem_params)
      @redeem_request.update_transaction_points if @redeem_request.retailer_other?
    end

    redirect_back
  end

  private

  def redeem_params
    params.fetch(:redeem_request).permit(:coupon_code, :comment, :points, :status)
  end

end
