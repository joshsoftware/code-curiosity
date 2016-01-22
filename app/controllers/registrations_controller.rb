class RegistrationsController < Devise::RegistrationsController 

  private

  def sign_up_params
    params.require(:user).permit(:email, :github_handle, :name)
  end
end
