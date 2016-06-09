class GroupsController < ApplicationController
  include GroupHelper
  before_action :authenticate_user!
  before_action :find_group, except: [:index, :new, :create]

  def index
    @groups = current_user.groups.page(params[:page])
  end

  def new
    @group = Group.new
  end

  def show
  end

  def create
    @group = current_user.groups.build(group_params)
    @group.owner = current_user

    if @group.save
      redirect_to group_path(@group)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @group.update_attributes(group_params)
      redirect_to group_path(@group)
    else
      render :edit
    end
  end

  def destroy
    @group.destroy

    redirect_to groups_path
  end

  private

  def group_params
    params.fetch(:group).permit(:name, :description)
  end
end
