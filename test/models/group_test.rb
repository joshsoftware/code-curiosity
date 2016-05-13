require "test_helper"

class GroupTest < ActiveSupport::TestCase
  def group
    @group ||= Group.new
  end

  def test_valid
    assert group.valid?
  end
end
