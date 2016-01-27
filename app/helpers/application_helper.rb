module ApplicationHelper
  def is_active(action, contr)
    return 'active' if action == params[:action] && contr == params[:controller]
  end

  def avatar_url
    current_user.avatar_url || 'http://robohash.org/dummy?set=3&size=160x160'
  end

  def github_url
    "http://github.com/#{current_user.github_handle}"
  end

end
