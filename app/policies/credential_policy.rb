class CredentialPolicy < ApplicationPolicy
  def create? = system_admin? || (organization_admin? && same_organization?)
  def update? = create?

  def destroy? = system_admin?

  private

  def same_organization?
    user && user_organization_id == record.organization_id
  end
end
