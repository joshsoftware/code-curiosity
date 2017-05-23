class Users::OmniauthCallbacksController < ApplicationController
  skip_before_action :current_round
  before_action :authenticate_user!, except: [:github, :failure]

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if request.env["omniauth.params"].present? && request.env["omniauth.params"]["user"] == "Sponsorer"
      @role = Role.find_or_create_by(name: 'Sponsorer')
      
      #fresh login of a non existing user as sponsorer
      if @user.last_sign_in_at == nil
        session[:modal] = true
      else
        #existing user
        session[:modal] = true unless @user.is_sponsorer? #detects first time login as sponsorer
      end

      @user.roles << @role unless @user.is_sponsorer?
      sign_in :user, @user
      redirect_to sponsorer_details_path #redirect to fill sponsor details
      flash[:notice] = "Signed in as sponsorer"

      return
    end

    #normal user sign in
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
