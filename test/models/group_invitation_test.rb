require "test_helper"

class GroupInvitationTest < ActiveSupport::TestCase

  def group_invitation
    @group_invitation ||= build(:group_invitation)
  end

  def test_valid
    assert group_invitation.valid?
  end
  
  def test_must_generate_token_before_creating_group_invitation
    group_invitation = create(:group_invitation, :token => nil)
    group_invitation.valid?
    assert_not_nil group_invitation.token
  end

end
