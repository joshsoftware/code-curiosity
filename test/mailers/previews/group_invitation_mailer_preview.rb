# Preview all emails at http://localhost:3000/rails/mailers/group_invitation_mailer
class GroupInvitationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/group_invitation_mailer/invite
  def invite
    invitation = GroupInvitation.first

    unless invitation
      user = User.first
      group = FactoryGirl.build(:group)
      group.members << user
      group.owner = user
      group.save

      invitation = group.group_invitations.create(user: User.limit(2)[1])
    end

    GroupInvitationMailer.invite(GroupInvitation.first)
  end

end
