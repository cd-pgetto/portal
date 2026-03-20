class Practice::InvitationsController < ApplicationController
  before_action :set_practice

  # POST /practices/:practice_id/invitations
  def create
    invitation = @practice.invitations.build(invitation_params.merge(invited_by: Current.user))
    authorize invitation

    unless invitation.valid?
      redirect_to edit_practice_path(@practice), alert: invitation.errors.full_messages.to_sentence
      return
    end

    # Replace any existing pending invitation for this email
    @practice.invitations.pending.find_by(email: invitation.email)&.destroy
    invitation.save!
    InvitationsMailer.invite(invitation).deliver_later
    redirect_to edit_practice_path(@practice), notice: "Invitation sent to #{invitation.email}."
  end

  # DELETE /practices/:practice_id/invitations/:id
  def destroy
    invitation = @practice.invitations.find(params[:id])
    authorize invitation
    invitation.destroy!
    redirect_to edit_practice_path(@practice), notice: "Invitation cancelled.", status: :see_other
  end

  private

  def set_practice
    @practice = Current.user.practices.find(params[:practice_id])
  end

  def invitation_params
    permitted = params.require(:invitation).permit(:email)
    permitted.merge(role: params.dig(:invitation, :role).presence_in(PracticeMember::REGULAR_ROLES))
  end
end
