class V1::TransactionsController < V1::BaseController
  #before_action :authenticate_user!

  def index
    user = User.find params[:id]
    render json: user.transactions.where(hidden: false).desc(:created_at)
  end
end
