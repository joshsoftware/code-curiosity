class Users::OmniauthCallbacksController < ApplicationController
  skip_before_action :current_round
  before_action :authenticate_user!, except: [:github, :failure] 

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect @user
  end

  def failure
    redirect_to root_path
  end
end
