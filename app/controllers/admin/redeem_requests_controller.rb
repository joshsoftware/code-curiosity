class Admin::RedeemRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    #status(false) = status(Open)
    #status(true) = status(Close)
    @status = params[:status] ? params[:status] : false
    @redeem_requests = RedeemRequest.where(:status => @status).desc(:created_at).page(params[:page]) 
    if request.xhr?
      respond_to do|format|
        format.js
      end
    end
  end

  def update
    @redeem_request = RedeemRequest.find(params[:id])
    if @redeem_request
      @redeem_request.update_attributes(redeem_params)
      @redeem_request.update_transaction_points if @redeem_request.retailer_other?
    end
    redirect_back
  end

  def destroy
    @redeem_request = RedeemRequest.find(params[:id])
    @redeem_request.destroy
    flash[:success] = "successfully deleted"
    redirect_to admin_redeem_requests_path
  end

  private

  def redeem_params
    params.fetch(:redeem_request).permit(:coupon_code, :comment, :points, :status)
  end

end
