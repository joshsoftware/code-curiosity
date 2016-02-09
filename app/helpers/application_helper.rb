module ApplicationHelper
  def is_active(action, contr)
    return 'active' if action == params[:action] && contr == params[:controller]
  end

  def avatar_url(user = nil)
    user = current_user if user.nil?
    user.avatar_url || 'http://robohash.org/dummy?set=3&size=160x160'
  end

  def github_url(user = nil)
     user = current_user if user.nil?
    "http://github.com/#{user.github_handle}"
  end

  def show_flash_notifications
    notification_js = ''

    flash.each do |t, msg|
      if msg.is_a?(String)
        notification_js << "flashNotification(\"#{msg}\", \"#{t}\");"
      end
    end

    notification_js
  end

  def round_date_format(date)
    date.strftime("%d %b %Y") if date
  end

end
