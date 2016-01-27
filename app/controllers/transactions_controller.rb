class TransactionsController < ApplicationController
  respond_to :html, :js

  def index
    @records_per_page = Kaminari.config.default_per_page
    @transactions = Transaction.where(user_id:params[:user_id]).order_by(:created_at => 'desc').page(params[:page]).per(@records_per_page)
  end
end
