class PracticeMemberPolicy < ApplicationPolicy
  def create? = user&.practice_admin_or_owner?(practice_id: record.practice_id)
  def update? = user&.practice_admin_or_owner?(practice_id: record.practice_id)
  def destroy? = user&.practice_admin_or_owner?(practice_id: record.practice_id)
end
