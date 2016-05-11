module OrganizationsHelper

  def is_org_admin?
    current_user ? @org.user_ids.include?(current_user.id) : false
  end
end
