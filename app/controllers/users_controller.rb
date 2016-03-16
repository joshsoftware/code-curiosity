class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def show
    @user = User.where(id: params[:id]).first || User.where(github_handle: params[:id]).first

    if @user
      render layout: current_user ? 'application' : 'public'
    else
      redirect_to root_url, notice: 'Invalid user name'
    end
  end
end
