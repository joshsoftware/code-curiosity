class GroupsController < ApplicationController
  before_action :work_in_progress
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

  def users
  end

  private

  def find_group
    @group = current_user.groups.where(id: params[:id]).first

    unless @group
      redirect_back(notice: I18n.t('messages.not_found'))
    end
  end

  def group_params
    params.fetch(:group).permit(:name, :description)
  end
end
