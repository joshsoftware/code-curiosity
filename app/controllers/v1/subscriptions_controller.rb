class V1::SubscriptionsController < V1::BaseController
  def index
    user = User.find params[:id]
    render json: user.subscriptions.where(:created_at.gt => Date.parse("Feb 2016")).desc(:created_at)
  end
end
