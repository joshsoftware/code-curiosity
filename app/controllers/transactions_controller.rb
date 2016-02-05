class TransactionsController < ApplicationController
  
  before_action :authenticate_user! 

  respond_to :html, :js

  def index
    @records_per_page = Kaminari.config.default_per_page
    @transactions = Transaction.where(user_id:current_user.id).order_by(:created_at => 'desc').page(params[:page]).per(@records_per_page)
  end
end
