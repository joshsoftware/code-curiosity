class Groups::MembersController < ApplicationController
  include GroupHelper
  before_action :authenticate_user!
  before_action :find_group
  before_action :is_group_admin, only: [:destroy, :create]
  before_action :find_and_check_membership, only: :create

  def index
  end

  def create
    return if @user.nil? || @is_member

    @invitation = @group.group_invitations.create(user: @user)
    flash.now[:notice] = I18n.t('group.member.create.invitation', { user: @user.github_handle })
  end

  def destroy
    @user = @group.members.where(id: params[:id]).first

    if @user
      @group.group_invitations.where(user: @user).destroy_all
      @group.members.delete(@user)
      flash.now[:notice] = I18n.t('group.member.destroy.success', { user: @user.github_handle, group: @group.name})
    else
      flash.now[:notice] = I18n.t('messages.not_found')
    end
  end

  def accept_invitation
    @group.accept_invitation(params[:token])

    redirect_to group_path(@group)
  end

  private

  def find_and_check_membership
    @user = User.where(id: params[:user_id]).first if params[:user_id].present?
    @is_member = false

    message = if @user.nil?
                I18n.t('group.member.create.user_not_found')
              elsif @group.members.where(id: @user).any?
                @is_member = true
                I18n.t('group.member.create.already_member', { user: @user.github_handle, group: @group.name})
              elsif @group.group_invitations.where(user_id: @user).any?
                @is_member = true
                I18n.t('group.member.create.already_invited',  { user: @user.github_handle, group: @group.name})
              end

    flash.now[:warning] = message if message
  end

  def is_group_admin
    return @group.owner == current_user
  end

end
