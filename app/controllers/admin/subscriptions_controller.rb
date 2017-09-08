class Admin::SubscriptionsController < ApplicationController
  include Admin::SubscriptionsHelper

  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @subscriptions = SponsorerDetail.asc(:subscription_status).page(params[:page])
  end

end
