class V1::TransactionsController < V1::BaseController
  before_action :authenticate_user!

  def index
    @records_per_page = Kaminari.config.default_per_page
    render json: Transaction.where(user_id: current_user.id).desc(:created_at).page(params[:page]).per(@records_per_page)
  end
end
