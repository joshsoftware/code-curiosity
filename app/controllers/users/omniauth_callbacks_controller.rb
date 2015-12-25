class Users::OmniauthCallbacksController < ApplicationController
  before_action :authenticate_user!, except: [:github, :failure] 

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect @user
  end

  def failure
    redirect_to root_path
  end
end
