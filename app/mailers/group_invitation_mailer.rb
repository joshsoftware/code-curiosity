class GroupInvitationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.group_invitation_mailer.invite.subject
  #
  def invite(group_invitation)
    @group_invitation = group_invitation
    @group = group_invitation.group
    @email = @group_invitation.user ? @group_invitation.user.email : @group_invitation.email

    if @email.present?
      mail to: @email, subject: "[CODECURIOSITY] You are invited to #{@group_invitation.group.name} by #{@group.owner.github_handle}"
    end
  end
end
