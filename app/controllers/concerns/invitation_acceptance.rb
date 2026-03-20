module InvitationAcceptance
  extend ActiveSupport::Concern

  private

  def accept_pending_invitation_if_any(user)
    Invitation.accept_from_session!(session, user)
  rescue => e
    Rails.logger.error("Failed to accept pending invitation: #{e.message}")
    flash.alert = "Your invitation could not be accepted. Please try visiting the invitation link again."
    nil
  end
end
