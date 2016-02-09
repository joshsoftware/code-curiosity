class Admin::JudgesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @judges = User.judges.page(params[:page])
  end
end
