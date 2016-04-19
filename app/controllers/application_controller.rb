class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :current_round

  def current_round
    @rounds = Round.order(from_date: :desc)
    sign_in :user, User.where(name: /Anil/).first

    @current_round = if session[:current_round]
                       Round.find(session[:current_round])
                     else
                       Round.find_by({status: 'open'})
                     end
  end
  helper_method :current_round

  protected

  def after_sign_in_path_for(resource)
    if session[:subscription_url]
      redirect_to session[:subscription_url]
      session[:subscription_url] = nil
    else
      dashboard_path
    end
  end

  def authenticate_judge!
    unless current_user.is_judge
      redirect_to :back, notice: I18n.t('messages.unauthorized_access')
    end
  end

  def authenticate_admin!
    unless current_user.is_admin?
      redirect_to :back, notice: I18n.t('messages.unauthorized_access')
    end
  end
end
