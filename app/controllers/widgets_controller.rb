class WidgetsController < ActionController::Base
  before_action :allow_iframe, :find_round

  def repo
    @repo = Repository.find(params[:id])

    unless @repo
      render plain: I18n.t('messages.not_found')
    end
  end

  def group
    @group = Group.find(params[:id])
    start_date = @group.created_at.to_time.beginning_of_month - 1.day

    @rounds = @rounds.where(:created_at.gt => start_date)
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
