class Admin::RedeemRequestsController < ApplicationController
  include Admin::RedeemRequestsHelper

  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :load_redeem_request, only: [:index, :download]

  def index
    @redeem_requests = @redeem_requests.where(store: params[:store]) if REDEEM['amazon_stores'].include?(params[:store])
    @redeem_requests = @redeem_requests.page(params[:page])
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
      @redeem_request.update_transaction_points
    end
    redirect_back
  end

  def destroy
    @redeem_request = RedeemRequest.find(params[:id])
    @redeem_request.destroy
    flash[:success] = "successfully deleted"
    redirect_to admin_redeem_requests_path
  end

  def download
    csv_string = CSV.generate do |csv|
      csv << ["User", "Gift Shop", "Store", "Points", "Cost", "Date", "Coupon Code", "Address", "Status"]
      @redeem_requests.each do |redeem_request|
        csv << [redeem_request.user.email, redeem_request.retailer, redeem_request.store,
          redeem_request.points, redeem_request.amount,
          redeem_request.updated_at.strftime(fmt='%F %T'), redeem_request.coupon_code,
          redeem_request.address, redeem_request.status]
      end
    end
   send_data csv_string, type: 'text/csv; header = present;', disposition: "filename = requests.csv"
  end

  private

  def redeem_params
    params.fetch(:redeem_request).permit(:coupon_code, :comment, :points, :status)
  end

  def load_redeem_request
    @status = params[:status] || false
    @redeem_requests = RedeemRequest.where(status: @status).desc(:created_at)
  end

end
