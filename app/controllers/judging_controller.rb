class JudgingController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_judge!

  def index
  end
end
