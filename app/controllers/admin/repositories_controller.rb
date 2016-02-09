class Admin::RepositoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @repos = Repository.all
  end
end
