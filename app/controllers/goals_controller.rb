class GoalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @goals = Goal.asc(:points)
  end
end
