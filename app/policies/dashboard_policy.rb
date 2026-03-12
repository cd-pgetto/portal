class DashboardPolicy < ApplicationPolicy
  def show? = system_admin?
end
