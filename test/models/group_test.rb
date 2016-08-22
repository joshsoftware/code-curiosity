require "test_helper"

class GroupTest < ActiveSupport::TestCase

  def test_name_must_be_present
    group = build(:group,:name => nil)
    group.valid?
    assert_not_empty group.errors[:name]
  end

  def test_description_must_be_present
    group = build(:group,:description => nil)
    group.valid?
    assert_not_empty group.errors[:description]
  end

  def test_group_owner_should_be_present
    group = create(:group)
    user = create(:user)
    group.owner = user
    assert_not_nil group.owner
  end

  def test_user_is_a_member_of_a_group
    group = create(:group)
    user = create(:user)
    group.members << user
    assert group.member?(user)
  end

  def test_user_is_not_a_member_of_a_group
    group = create(:group)
    user = create(:user)
    assert_not group.member?(user)
  end

  def test_group_should_not_accept_invitation_if_token_is_not_present
    group = create(:group)
    token = SecureRandom.base64(24).tr('0+/=', 'A0lk')
    assert_not group.accept_invitation(token)
  end

  def test_group_must_accept_invitation_having_token_with_them
    group = create(:group)
    invitation = create(:group_invitation)
    group.group_invitations << invitation
    user = create(:user)
    user.group_invitations << invitation
    assert group.accept_invitation(invitation.token)
  end

  def test_user_is_not_invited_if_group_invitation_is_not_present
    group = create(:group)
    user = create(:user)
    assert_not group.invited?
  end

  def test_user_is_invited_if_group_invitation_is_present
    group = create(:group)
    user = create(:user)
    invitation = create(:group_invitation, user: user)
    group.group_invitations << invitation
    assert group.invited?(user: user)
  end

  def test_group_member_not_removed_if_member_is_the_owner
    group = create(:group)
    member = create(:user)
    group.members << member
    group.owner = member
    assert_not group.can_remove_member?(member)
  end

  def test_group_member_removed_if_current_user_is_member
    member = create(:user)
    group = create(:group)
    group.members << member
    current_user = member
    group.owner = group.members.first
    assert group.can_remove_member?(member, current_user)
  end

  def test_group_member_current_user_removed_if_current_user_is_owner
    member = create(:user)
    group = create(:group)
    group.members << member
    current_user = group.members.first
    group.owner = current_user
    assert group.can_remove_member?(member, current_user)
  end
  
end
