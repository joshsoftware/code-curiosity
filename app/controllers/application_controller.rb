class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :signout_old_login
  before_action :current_round
  helper_method :current_round

  protected

  def current_round
    @rounds = Round.order(from_date: :desc).limit(3)
    @current_round = if session[:current_round]
                       Round.find(session[:current_round])
                     else
                       Round.find_by({status: 'open'})
                     end
  end

  def signout_old_login
    if current_user && current_user.auth_token.blank?
      sign_out current_user
      redirect_to root_path
      return false
    end
  end

  def authenticate_judge!
    unless current_user.is_judge
      redirect_back(notice: I18n.t('messages.unauthorized_access'))
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
