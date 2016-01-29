class SubscriptionsController < ApplicationController
  before_action :set_subscription_url
  before_action :authenticate_user!
  before_action :check_user_id_with_current_user

  def subscribe 
    @round = Round.order_by(created_at: :desc).first 

    if @round.subscriptions.where(:user_id => current_user).any?
      redirect_to root_path, :notice => I18n.t('messages.already_subscribed')
    else
      if current_user.points >= WALLET_CONFIG['subscription_amount']   
        current_user.subscriptions.create(round: @round)
        redirect_to root_path, :notice => I18n.t('messages.subscription_successfull')
      else
        redirect_to root_path, :notice => I18n.t("messages.insufficient_points")
      end
    end

  end

  private

  def check_user_id_with_current_user
    unless BSON::ObjectId.from_string(params[:id]) == current_user.id
      redirect_to root_path, :notice => I18n.t('messages.unauthorized_access') 
    end
  end

  def set_subscription_url
    session[:subscription_url] = request.url 
  end
end
