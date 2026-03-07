class DentalModelPolicy < ApplicationPolicy
  def show?
    system_admin? || practice_member?
  end

  def create?
    system_admin? || practice_member?
  end

  def update?
    system_admin? || practice_member?
  end

  def destroy? = system_admin?

  private

  def practice_member?
    user&.practice_memberships&.exists?(practice_id: record.practice_id)
  end
end
