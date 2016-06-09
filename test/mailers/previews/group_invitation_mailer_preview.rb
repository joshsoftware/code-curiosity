# Preview all emails at http://localhost:3000/rails/mailers/group_invitation_mailer
class GroupInvitationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/group_invitation_mailer/invite
  def invite
    GroupInvitationMailer.invite
  end

end
