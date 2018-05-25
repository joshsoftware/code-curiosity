class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :signout_old_login

  protected

  def signout_old_login
    if current_user && current_user.auth_token.blank?
      sign_out current_user
      redirect_to root_path
      return false
    end
  end

  def authenticate_admin!
    unless current_user.is_admin?
      redirect_back(notice: I18n.t('messages.unauthorized_access'))
    end
  end

  def authenticate_sponsor!
    if current_user && !current_user.is_sponsorer?
      redirect_back(notice: I18n.t('messages.unauthorized_access'))
    end
  end

  def redirect_back(opts = {})
    redirect_to(request.env['HTTP_REFERER'] || root_path, opts)
  end

  def work_in_progress
    redirect_back
    return false
  end
end
