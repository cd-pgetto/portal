class UserPolicy < ApplicationPolicy
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
