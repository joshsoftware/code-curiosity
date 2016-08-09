module GroupHelper
  def find_group
    if current_user
      @group = current_user.groups.where(id: (params[:group_id] || params[:id])).first
    else
      @group = Group.where(id: params[:id]).first
    end

    unless @group
      redirect_back(notice: I18n.t('messages.not_found'))
    end
  end

  def is_group_admin
    render json: nil, status: :unauthorized unless @group.owner == current_user
  end

  def is_admin
    render json: nil, status: :unauthorized unless current_user.is_admin?
  end

end
