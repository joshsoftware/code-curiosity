require "test_helper"

class GroupInvitationTest < ActiveSupport::TestCase
  def group_invitation
    @group_invitation ||= GroupInvitation.new
  end

  def test_valid
    assert group_invitation.valid?
  end
end
