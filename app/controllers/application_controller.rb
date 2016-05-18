class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :signout_old_login, :select_goal
  before_action :current_round

  def current_round
    @rounds = Round.order(from_date: :desc).limit(3)
    @current_round = if session[:current_round]
                       Round.find(session[:current_round])
                     else
                       Round.find_by({status: 'open'})
                     end
  end

  helper_method :current_round

  protected

  def signout_old_login
    if current_user && current_user.auth_token.blank?
      sign_out current_user
      redirect_to root_path
      return false
    end
  end

  def select_goal
    return true unless current_user
    return true if params[:controller] == 'goals' && params[:action] == 'index'
    return true if params[:action] == 'set_goal' || params[:controller] == 'devise/sessions'

    if current_user.goal.blank?
      redirect_to goals_path, notice: I18n.t('goal.please_select')
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

  def redirect_back(opts = {})
    redirect_to(request.env["HTTP_REFERER"] || root_path, opts)
  end
end
