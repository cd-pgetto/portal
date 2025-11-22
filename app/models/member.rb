# == Schema Information
#
# Table name: members
# Database name: primary
#
#  id                 :uuid             not null, primary key
#  business_unit_type :string           default("Organization"), not null
#  role               :enum             default("member"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  business_unit_id   :uuid             not null
#  user_id            :uuid             not null
#
# Indexes
#
#  index_members_on_business_unit_id_and_business_unit_type  (business_unit_id,business_unit_type)
#  index_members_on_user_id                                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (business_unit_id => organizations.id)
#  fk_rails_...  (user_id => users.id)
#
class Member < ApplicationRecord
  belongs_to :business_unit, polymorphic: true
  belongs_to :user

  enum :role, {owner: "owner", admin: "admin", member: "member", inactive: "inactive"}
end
