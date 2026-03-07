class IdentityProviderPolicy < ApplicationPolicy
  def index? = system_admin?
  def show? = system_admin?

  def create?
    system_admin? || org_admin_can_manage?
  end

  def edit? = update?

  def update?
    system_admin? || org_admin_can_manage?
  end

  def destroy? = system_admin?

  private

  def org_admin_can_manage?
    return false unless organization_admin?
    return false unless record.respond_to?(:dedicated?) && record.dedicated?

    record.respond_to?(:organization_ids) && record.organization_ids.include?(user_organization_id)
  end
end
