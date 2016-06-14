class Users::OmniauthCallbacksController < ApplicationController
  skip_before_action :current_round
  before_action :authenticate_user!, except: [:github, :failure]

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in :user, @user

    if session[:group_invitation_url].present?
      redirect_to session.delete(:group_invitation_url)
    else
      redirect_to root_path
    end
  end

  def failure
    redirect_to root_path
  end
end
