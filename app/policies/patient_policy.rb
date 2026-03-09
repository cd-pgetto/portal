class PatientPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user&.system_admin?
        scope.all
      elsif user
        scope.where(practice_id: user.practice_memberships.select(:practice_id))
      else
        scope.none
      end
    end

    private

    attr_reader :user, :scope
  end

  def index? = system_admin? || practice_member?
  def show? = index?
  def create? = index?
  def update? = index?

  def destroy? = system_admin?

  private

  def practice_member?
    user&.practice_memberships&.exists?(practice_id: record.practice_id)
  end
end
