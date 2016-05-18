module GoalsHelper
  def color(index)
    ['green', 'red', 'yellow', 'blue'][index] || 'green'
  end

  def points_format(points)
    content_tag :span, points, class: 'points'
  end

  def selected_goal?(goal)
    current_user.current_subscription.goal_id == goal.id
  end
end
