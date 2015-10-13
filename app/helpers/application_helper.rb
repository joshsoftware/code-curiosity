module ApplicationHelper
  def is_active(action, contr)
    return 'active' if action == params[:action] && contr == params[:controller]
  end
end
