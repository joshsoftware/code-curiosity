class Groups::MembersController < ApplicationController
  include GroupHelper

  before_action :set_session_url, only: :accept_invitation
  before_action :authenticate_user!
  before_action :find_group, except: :accept_invitation
  before_action :is_group_admin, only: [:create]
  before_action :find_and_check_membership, only: :create

  def index
  end

  def create
    return if @is_member || (@user.nil? && @email.nil?)

    @invitation = @group.group_invitations.create(user: @user, email: @email)
    flash.now[:notice] = I18n.t('group.member.create.invitation', {
      user: @user ? @user.github_handle : @email
    })
  end

  def destroy
    if is_group_admin
      @user = @group.members.where(id: params[:id]).first
    elsif @group.member?(current_user)
      @user = current_user
    end

    if @user
      @group.group_invitations.where(user: @user).destroy_all
      @group.members.delete(@user)
      flash.now[:notice] = I18n.t('group.member.destroy.success', { user: @user.github_handle, group: @group.name})
    else
      flash.now[:notice] = I18n.t('messages.not_found')
    end
  end

  def accept_invitation
    @group = Group.find(params[:group_id])
    @group.accept_invitation(params[:token])

    redirect_to group_path(@group)
  end

  private

  def find_and_check_membership
    if Devise.email_regexp =~ params[:user_search]
      @email = params[:user_search]
      @user = User.where(email: @email).first
    end

    @user = User.where(id: params[:user_id]).first if @user.nil?
    @is_member = false

    message = if @user.nil? && @email.nil?
                I18n.t('group.member.create.user_not_found')
              elsif @group.member?(@user)
                @is_member = true
                I18n.t('group.member.create.already_member', { user: @user.github_handle, group: @group.name})
              elsif @group.invited?(user: @user, email: @email)
                @is_member = true
                I18n.t('group.member.create.already_invited',  { user: @user ? @user.github_handle : @email, group: @group.name})
              elsif @email
                nil
              end

    flash.now[:warning] = message if message
  end

  def set_session_url
    session[:group_invitation_url] = request.url
  end

end
