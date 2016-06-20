class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @users = User.contestants.desc(:created_at).page(params[:page])
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

  def search
    if params[:q].blank?
      redirect_to admin_users_path
      return
    end

    @users = User.where(github_handle: params[:q])
    @users = User.where(email: params[:q]) if @users.none?
    @users = @users.page(1)

    render :index
  end
end
