class OrganizationPolicy < ApplicationPolicy
  def show?
    system_admin? || (user && user_organization_id == record.id)
  end

  def index? = system_admin?

  def create? = system_admin?

  def update?
    system_admin? || (organization_admin? && user && user_organization_id == record.id)
  end

  def destroy? = system_admin?
end
