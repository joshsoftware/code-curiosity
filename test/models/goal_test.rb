require "test_helper"

class GoalTest < ActiveSupport::TestCase

  def test_name_should_be_present
    goal = build(:goal, :name => nil)
    goal.valid?
    assert_not_empty goal.errors[:name]
  end

  def test_points_should_be_integer
    goal = build(:goal, :points => 10.2)
    assert_not goal.valid?
  end

  def test_default_goal_must_be_hiker
    goal = build(:goal, :name => 'Mountaineer')
    assert_not Goal.default_goal
  end

  def test_info_of_goal_must_be_loaded
    goal = build(:goal)
    assert_not_nil Goal.info
  end

  def test_info_of_goal_should_not_be_nil
    goal = create(:goal, :name => 'Mountaineer')
    assert_not_nil goal.info
  end

  def test_setup
    goal = create(:goal, :name => 'Hiker')
    assert_equal Goal.setup.count, 3
  end

end
