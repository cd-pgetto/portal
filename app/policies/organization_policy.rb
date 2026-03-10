class OrganizationPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user&.system_admin?
        scope.all
      else
        scope.none
      end
    end

    private

    attr_reader :user, :scope
  end

  def show?
    system_admin? || (user && user_organization_id == record.id)
  end

  def update?
    system_admin? || (organization_admin? && user && user_organization_id == record.id)
  end

  def index? = system_admin?
  def create? = system_admin?
  def destroy? = system_admin?
end
