class WidgetsController < ActionController::Base
  before_filter :allow_iframe, :find_round

  def repo
    @repo = Repository.find(params[:id])

    unless @repo
      render plain: I18.t('messages.not_found')
    end
  end

  private

  def allow_iframe
    response.headers.except!('X-Frame-Options')
  end

  def find_round
    @current_round = Round.find(params[:round_id]) if params[:round_id].present?
    @current_round = Round.opened unless @current_round
    @rounds = Round.order(from_date: :desc).limit(3)
  end
end
