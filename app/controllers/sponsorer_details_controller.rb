class SponsorerDetailsController < ApplicationController
  include SponsorerHelper
  require "stripe"
  # after_action :set_sponsorer, only: [:create]
  before_action :authenticate_user!
  # before_action :authenticate_sponsor!, except: [:new, :create]

  def index
    @user = current_user
    @sponsor = @user.sponsorer_detail
  end

  def new
    @sponsorer_detail = SponsorerDetail.new
  end

  def create
    @sponsorer = SponsorerDetail.new(sponsorer_params)
    @sponsorer.user_id = current_user.id
    
    plan_id = @sponsorer.payment_plan+"-"+@sponsorer.sponsorer_type.downcase
    
    customer = createStripeCustomer(current_user.email, params[:stripeToken])

    @sponsorer.stripe_customer_id = customer.id

    subscription = createStripeSubscription(customer.id, plan_id)
    
    @sponsorer.stripe_subscription_id = subscription.id

    @sponsorer.subscribed_at = Time.at(subscription.current_period_start).to_datetime 
    @sponsorer.subscription_expires_at = Time.at(subscription.current_period_end).to_datetime

    if @sponsorer.save
      flash[:notice] = "saved sponsorship details successfully"
      redirect_to sponsorer_details_path  #sponsorer dashboard
      # render 'new'
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.js
      end
    end
  end

  private

  def sponsorer_params
    params.require(:sponsorer_detail).permit!
  end
end
