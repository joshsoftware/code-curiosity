class Admin::RoundsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @rounds = Round.order(from_date: :desc).page(params[:page])
  end

  def mark_as_close
    @round = Round.find(params[:round_id])
    @round.round_close
    redirect_to admin_rounds_path
  end
end
