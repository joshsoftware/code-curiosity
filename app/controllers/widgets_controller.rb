class WidgetsController < ActionController::Base
  before_action :allow_iframe

  def repo
    @repo = Repository.find(params[:id])

    unless @repo
      render plain: I18n.t('messages.not_found')
    end
  end

  private

  def allow_iframe
    response.headers.except!('X-Frame-Options')
  end
end
