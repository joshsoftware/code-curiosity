module GroupHelper
  def find_group
    @group = current_user.groups.where(id: (params[:group_id] || params[:id])).first

    unless @group
      redirect_back(notice: I18n.t('messages.not_found'))
    end
  end
end
