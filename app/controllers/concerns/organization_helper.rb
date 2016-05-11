module OrganizationHelper
  private

  def authenticate_org!
    @org = Organization.find(params[:organization_id] || params[:id])

    if @org && current_user.organization_ids.include?(@org.id)
      return true
    end

    respond_to do |format|
      format.html { redirect_back notice: I18n.t('messages.not_found') }
      format.js {  render nothing: true, stauts: 401 }
    end
  end
end
