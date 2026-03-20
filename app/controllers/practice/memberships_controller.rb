class Practice::MembershipsController < ApplicationController
  before_action :set_practice
  before_action :set_membership, only: [:destroy]

  # POST /practices/:practice_id/memberships
  # Adds an existing user to the practice by email.
  def create
    authorize @practice, :edit?

    user = User.find_by(email_address: membership_params[:email_address])
    unless user
      redirect_to edit_practice_path(@practice), alert: "No user found with that email address." and return
    end

    unless membership_params[:role]
      redirect_to edit_practice_path(@practice), alert: "You are not authorized to assign that role." and return
    end

    membership = @practice.members.build(user: user, role: membership_params[:role])

    if membership.save
      ensure_organization_membership(user)
      redirect_to edit_practice_path(@practice), notice: "#{membership.role.humanize} role added for #{user.full_name}."
    else
      redirect_to edit_practice_path(@practice), alert: membership.errors.full_messages.to_sentence
    end
  end

  # DELETE /practices/:practice_id/memberships/:id
  def destroy
    authorize @membership
    @membership.destroy!
    redirect_to edit_practice_path(@practice), notice: "Member removed from practice.", status: :see_other
  end

  private

  def set_practice
    @practice = Current.user.practices.find(params[:practice_id])
  end

  def set_membership
    @membership = @practice.members.find(params[:id])
  end

  def membership_params
    permitted = params.require(:practice_member).permit(:email_address)
    permitted.merge(role: params.dig(:practice_member, :role).presence_in(assignable_roles))
  end

  def assignable_roles
    if Current.user.practice_memberships.exists?(practice: @practice, role: :owner)
      PracticeMember.roles.keys
    else
      PracticeMember.roles.keys - ["owner"]
    end
  end

  def ensure_organization_membership(user)
    user.create_organization_membership(organization: @practice.organization) unless user.organization_membership
  end
end
