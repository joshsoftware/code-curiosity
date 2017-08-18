class SponsorerDetailsController < ApplicationController
  include SponsorerHelper
  require "stripe"
  # after_action :set_sponsorer, only: [:create]
  before_action :authenticate_user!
  # before_action :authenticate_sponsor!, except: [:new, :create]
  skip_before_action :select_goal
  before_action :load_sponsorer, only: [:update_card, :cancel_subscription]

  def index
    @user = current_user
    @sponsor = @user.sponsorer_detail
    if @sponsor
      @card = SponsorerDetail.get_credit_card(@sponsor.stripe_customer_id)
      @payments = Payment.where(:sponsorer_detail_id.in => @user.sponsorer_details.collect(&:id)).desc(:created_at).page params[:page]
    end
  end

  def new
    session[:type] = params[:type] || session[:type] || 'Individual'
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
          redirect_to sponsorer_details_path  #sponsorer dashboard
          flash[:notice] = "saved sponsorship details successfully"
        end
      end
    else
      flash[:error] = @sponsorer.errors.full_messages.join(',')
    end
  end

  def update_card
    begin
      customer = Stripe::Customer.retrieve(@sponsor.stripe_customer_id)
      customer.source = params[:stripeToken]
    rescue Stripe::StripeError => e
      flash[:error] = e.message
    else
      customer.save
      flash[:notice] = 'Your card has been updated successfully'
    end
    redirect_to sponsorer_details_path
  end

  def cancel_subscription
    begin
      delete_subscription(@sponsor.stripe_subscription_id)
      @sponsor.user.set({is_sponsorer: false })
    rescue Stripe::StripeError => e
      flash[:error] = e.message
    else
      flash[:notice] = "Your subscription has been cancelled successfully"
    end
    redirect_to sponsorer_details_path
  end

  private

  def sponsorer_params
    params.require(:sponsorer_detail).permit!
  end

  def load_sponsorer
    @sponsor = current_user.sponsorer_details.asc(:created_at).last
  end
end
