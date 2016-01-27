class RegistrationsController < Devise::RegistrationsController

  before_action :redirect_to_home

  private

  def redirect_to_home
    redierect_to root_path
  end

  def sign_up_params
    params.require(:user).permit(:email, :github_handle, :password, :password_confirmation, :name)
  end

end
