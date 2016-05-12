class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @users = User.all.page(params[:page])
  end

  def mark_as_judge
    User.find(params[:user_id]).set(is_judge: params[:flag])
    redirect_to admin_users_path
  end

  def login_as
    user = User.find(params[:user_id])

    if user
      sign_in :user, user
    end

    redirect_to root_path
  end
end
