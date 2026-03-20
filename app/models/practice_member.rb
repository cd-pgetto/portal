# == Schema Information
#
# Table name: practice_members
# Database name: primary
#
#  id          :uuid             not null, primary key
#  active      :boolean          default(TRUE), not null
#  role        :enum             default("member"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  practice_id :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_practice_members_on_practice_id                       (practice_id)
#  index_practice_members_on_user_id                           (user_id)
#  index_practice_members_on_user_id_and_practice_id_and_role  (user_id,practice_id,role) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (practice_id => practices.id)
#  fk_rails_...  (user_id => users.id)
#
class PracticeMember < ApplicationRecord
  belongs_to :practice
  belongs_to :user

  validates :user_id, uniqueness: {scope: [:practice_id, :role], message: "already has this role in the practice"}

  enum :role, {owner: "owner", admin: "admin", member: "member", dentist: "dentist", hygienist: "hygienist",
    assistant: "assistant"}

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :admin_or_owner, -> { active.where(role: [:owner, :admin]) }
  scope :admin_or_owner_in, ->(practice_id) { admin_or_owner.where(practice_id: practice_id) }
end
