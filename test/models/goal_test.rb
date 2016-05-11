require "test_helper"

class GoalTest < ActiveSupport::TestCase
  def goal
    @goal ||= Goal.new
  end

  def test_valid
    assert goal.valid?
  end
end
