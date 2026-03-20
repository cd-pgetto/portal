class InvitationsMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @token = invitation.generate_token_for(:acceptance)
    mail to: invitation.email, subject: "You've been invited to join #{invitation.practice.name}"
  end
end
