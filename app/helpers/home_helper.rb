module HomeHelper

  def select_avatar(sponsorer)
    if sponsorer.avatar?
      sponsorer.avatar
    else
      avatar_url(sponsorer.user)
    end
  end

  def redirect(sponsorer)
    if sponsorer.organization_url?
      sponsorer.organization_url
    else
      user_path(sponsorer.user.github_handle.downcase)
    end
  end

  def widget_class
    if @size > 2
      'col-md-4'
    elsif @size == 2
      'col-md-6'
    else
      'col-md-12'
    end
  end
end
