require "test_helper"

class GoalsHelperTest < ActionView::TestCase
  test 'color' do
    assert_equal color(1), 'red'
    assert_equal color(999), 'green'
  end

  test 'points_format' do
    assert_equal points_format(15), (content_tag :span, 15, class: 'points')
  end

  test 'selected_goal' do
    goal = create :goal
    assert selected_goal?(goal)
  end

  private

  def current_user
    round = create :round, :open
    user = create :user, auth_token: 'dah123rty', goal: Goal.last
    create :subscription, user: user, round: round, goal: Goal.last
    user
  end
end
