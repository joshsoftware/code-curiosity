class HackathonsController < ApplicationController
  include HackathonsHelper

  before_action :authenticate_user!, except: [ :show ]

  def create
    render :success
  end
end
