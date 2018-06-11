class DashboardController < ApplicationController
  include ContributionHelper
  before_action :authenticate_user!, except: [:webhook]

  def index
    contribution_data
  end

  def webhook
    render :nothing
  end
end
