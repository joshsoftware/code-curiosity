class SponsorerDetailsController < ApplicationController
  include SponsorerHelper
  # after_action :set_sponsorer, only: [:create]
  before_action :authenticate_user!
  # before_action :authenticate_sponsor!, except: [:new, :create]

  def new
    @sponsorer_detail = SponsorerDetail.new
  end

  def create
    @sponsorer = SponsorerDetail.new(sponsorer_params)
    @sponsorer.user_id = current_user.id
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
