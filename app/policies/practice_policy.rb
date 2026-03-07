class PracticePolicy < ApplicationPolicy
  def index?
    system_admin? || user&.organization_membership.present?
  end

  def show?
    system_admin? || practice_member?
  end

  def select?
    system_admin? || practice_member?
  end

  def create? = system_admin?

  def edit?
    system_admin? || admin_or_owner_member?
  end

  def update?
    system_admin? || admin_or_owner_member?
  end

  def destroy? = system_admin?

  private

  def practice_member?
    user&.practice_memberships&.exists?(practice_id: record.id)
  end

  def admin_or_owner_member?
    user&.practice_memberships&.where(role: [:owner, :admin])&.exists?(practice_id: record.id)
  end
end
