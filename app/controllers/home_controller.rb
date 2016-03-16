class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to user_path(current_user)
      return
    end
  end
end
