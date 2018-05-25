class Users::OmniauthCallbacksController < ApplicationController
  before_action :authenticate_user!, except: [:github, :failure]

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])

    #normal user sign in
    sign_in :user, @user

    redirect_to dashboard_path
    flash[:notice] = "Signed in"
  end

  def failure
    redirect_to root_path
  end
end
