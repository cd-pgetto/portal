class InvitationsController < ApplicationController
  include InvitationAcceptance

  allow_unauthenticated_access only: [:show]
  skip_after_action :verify_authorized

  before_action :set_invitation

  # GET /invitations/:token
  # Landing page — shows invitation details and sign-up/sign-in options for
  # unauthenticated users, or an Accept button for authenticated users.
  def show
    unless @invitation&.pending?
      redirect_to root_path, alert: "This invitation is invalid or has expired."
      return
    end

    session[:invitation_token] = params[:token]
    org = @invitation.practice.organization
    render Views::Invitations::Show.new(
      invitation: @invitation,
      user: User.new(email_address: @invitation.email, registration_step: 2),
      identity_providers: org.identity_providers,
      password_auth_allowed: org.password_auth_allowed?
    )
  end

  # PATCH /invitations/:token/accept
  # Accepts the invitation for the currently signed-in user.
  def accept
    unless @invitation&.pending?
      redirect_to root_path, alert: "This invitation is invalid or has expired."
      return
    end

    unless Current.user.email_address == @invitation.email
      redirect_to invitation_path(params[:token]), alert: "This invitation was sent to #{@invitation.email}. Please sign in with that account."
      return
    end

    @invitation.accept!(Current.user)
    redirect_to practice_path(@invitation.practice), notice: "You have joined #{@invitation.practice.name}."
  end

  private

  def set_invitation
    @invitation = Invitation.find_by_token_for(:acceptance, params[:token])
  end
end
