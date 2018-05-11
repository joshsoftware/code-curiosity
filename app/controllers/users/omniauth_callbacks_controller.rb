class Users::OmniauthCallbacksController < ApplicationController
  skip_before_action :current_round
  before_action :authenticate_user!, except: [:github, :failure]

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if request.env["omniauth.params"].present? && ['Individual', 'Organization'].include?(request.env["omniauth.params"]["user"])
      @role = Role.find_or_create_by(name: 'Sponsorer')
      #fresh login of a non existing user as sponsorer
      session[:sponsor] = true
      session[:type] = request.env["omniauth.params"]["user"] || 'Individual'
      sign_in :user, @user
      redirect_to dashboard_path #redirect to fill sponsor details
      flash[:notice] = "Signed in as sponsorer"
      return
    end

    #normal user sign in
    sign_in :user, @user

    if session[:group_invitation_url].present?
      redirect_to session.delete(:group_invitation_url)
    else
      redirect_to dashboard_path
    end
  end

  def failure
    redirect_to root_path
  end
end
