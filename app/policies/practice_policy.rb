class PracticePolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user&.system_admin?
        scope.all
      elsif user
        scope.where(id: user.practice_memberships.select(:practice_id))
      else
        scope.none
      end
    end

    private

    attr_reader :user, :scope
  end

  def index? = system_admin? || practice_member?
  def show? = index?
  def select? = index?

  def edit? = system_admin? || admin_or_owner_member?
  def update? = edit?

  def create? = system_admin?
  def destroy? = create?

  private

  def practice_member?
    if record.is_a?(Class)
      user&.practice_memberships&.exists?
    else
      user&.practice_memberships&.exists?(practice_id: record.id)
    end
  end

  def admin_or_owner_member?
    user&.practice_memberships&.where(role: [:owner, :admin])&.exists?(practice_id: record.id)
  end
end
