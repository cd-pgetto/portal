module InvitationAcceptance
  extend ActiveSupport::Concern

  private

  def accept_pending_invitation_if_any(user)
    Invitation.accept_from_session!(session, user)
  rescue => e
    Rails.logger.error("Failed to accept pending invitation: #{e.message}")
    nil
  end
end
