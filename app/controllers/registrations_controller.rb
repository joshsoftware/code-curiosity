class RegistrationsController < Devise::RegistrationsController
  
  before_action :redirect_to_home, except: [:terms_and_conditions]

  def terms_and_conditions
    if params[:terms_and_conditions]
      current_user.set(terms_and_conditions: params[:terms_and_conditions])
      redirect_to dashboard_path
    else
      render 'terms_and_conditions'
    end
  end

  private

  def redirect_to_home
    redirect_to root_path
  end

  def sign_up_params
    params.require(:user).permit(:email, :github_handle, :name)
  end

end
