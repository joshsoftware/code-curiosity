require "test_helper"

class GroupInvitationMailerTest < ActionMailer::TestCase
  include ActiveJob::TestHelper

  before :all do
    @group = create(:group)
    user = create(:user)
    @group.owner = user
  end

  test "group_invitation_mail is enqueued to be delivered later" do
    assert_enqueued_jobs 1 do
      group_invitation = create(:group_invitation, group: @group)
    end
  end

  test "group_invitation_mail should be delivered" do
    group_invitation = create(:group_invitation, group: @group)
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      GroupInvitationMailer.invite(group_invitation).deliver_now
    end
  end

end
