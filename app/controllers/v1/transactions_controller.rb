class V1::TransactionsController < V1::BaseController
  before_action :authenticate_user!

  def index
    render json: current_user.transactions.desc(:created_at)
  end
end
