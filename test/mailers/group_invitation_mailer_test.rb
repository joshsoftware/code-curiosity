require "test_helper"

class GroupInvitationMailerTest < ActionMailer::TestCase
  def test_invite
    mail = GroupInvitationMailer.invite
    assert_equal "Invite", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
