class SponsorerDetailsController < ApplicationController
  include SponsorerHelper
  require "stripe"
  # after_action :set_sponsorer, only: [:create]
  before_action :authenticate_user!
  # before_action :authenticate_sponsor!, except: [:new, :create]
  skip_before_action :select_goal

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
    if @sponsorer.valid?
      begin
        plan_id = @sponsorer.payment_plan+"-"+@sponsorer.sponsorer_type.downcase

        customer = createStripeCustomer(current_user.email, params[:stripeToken], plan_id)

        @sponsorer.stripe_customer_id = customer.id
        
        subscription = customer.subscriptions.data.first
        @sponsorer.stripe_subscription_id = subscription.id
        @sponsorer.subscribed_at = Time.at(subscription.created).to_datetime
        @sponsorer.subscription_expires_at = Time.at(subscription.current_period_end).to_datetime
        @sponsorer.subscription_status = subscription.status

      rescue Stripe::StripeError => e
        flash[:error] = e.message
      else
        if @sponsorer.save
          SponsorMailer.notify_subscription_details(@sponsorer.user_id.to_s, @sponsorer.payment_plan, SPONSOR[@sponsorer.sponsorer_type.downcase][@sponsorer.payment_plan]).deliver_later
          redirect_to sponsorer_details_path  #sponsorer dashboard
          flash[:notice] = "saved sponsorship details successfully"
        end
      end
    else
      flash[:error] = @sponsorer.errors.full_messages.join(',')
    end
  end

  private

  def sponsorer_params
    params.require(:sponsorer_detail).permit!
  end
end
