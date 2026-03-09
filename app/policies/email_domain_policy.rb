class EmailDomainPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user&.system_admin?
        scope.all
      elsif user
        scope.where(organization_id: user.organization_membership&.organization_id)
      else
        scope.none
      end
    end

    private

    attr_reader :user, :scope
  end

  def show? = system_admin? || same_organization?

  def index? = user.present?

  def create? = system_admin? || (organization_admin? && same_organization?)
  def update? = create?

  def destroy? = system_admin?

  private

  def same_organization?
    user && user_organization_id == record.organization_id
  end
end
