class EmailDomainPolicy < ApplicationPolicy
  def show?
    system_admin? || same_organization?
  end

  def index? = system_admin?

  def create?
    system_admin? || (organization_admin? && same_organization?)
  end

  def update?
    system_admin? || (organization_admin? && same_organization?)
  end

  def destroy? = system_admin?

  private

  def same_organization?
    user && user_organization_id == record.organization_id
  end
end
