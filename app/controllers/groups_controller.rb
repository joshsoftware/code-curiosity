class GroupsController < ApplicationController
  include GroupHelper

  before_action :authenticate_user!, except: [ :show ]
  before_action :find_group, except: [:index, :new, :create, :feature]
  before_action :is_group_admin, only: [:update, :destroy]
  before_action :is_admin, only: [:feature]
  
  def index
    @groups = current_user.is_admin? ? Group.order_by(name: :desc).page(params[:page]) : current_user.groups.page(params[:page])
  end

  def new
    @group = Group.new
  end

  def show
    render layout: 'info' unless current_user 
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

  def feature
    @group = Group.where(id: params[:id]).first
    @group.update(is_featured: !@group.is_featured) 
    respond_to do |format|
      format.js { render 'groups/feature' }
    end
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
    params.fetch(:group).permit(:name, :description, :is_featured)
  end
end
