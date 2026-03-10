class UserPolicy < ApplicationPolicy
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

  def create?
    user.nil? || system_admin?
  end

  def show?
    system_admin? || user == record
  end

  def update?
    system_admin? || user == record
  end

  def edit? = update?

  def index? = system_admin?

  def destroy? = system_admin?
end
