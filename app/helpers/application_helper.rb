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

  def format_points(points)
    return points if points < 9999

    "#{(points/1000.0).round(1)}k"
  end

  def judge_rating_path(resource)
    if @org
      rate_activity_organization_path(@org, resource.collection_name, resource)
    else
      rate_activity_judging_index_path(resource.collection_name, resource)
    end
  end

  def add_judge_comment_path(resource)
    if @org
      comment_organization_path(@org, resource.collection_name, resource)
    else
      comment_judging_index_path(resource.collection_name, resource)
    end
  end

  def judges_comments_path(resource)
    if @org
      comments_organization_path(@org, resource.collection_name, resource)
    else
      comments_judging_index(resource.collection_name, resource)
    end
  end

end
