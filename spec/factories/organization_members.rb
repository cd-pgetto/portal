# == Schema Information
#
# Table name: organization_members
#
#  id              :uuid             not null, primary key
#  role            :enum             default("member"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid             not null
#  user_id         :uuid             not null
#
# Indexes
#
#  index_organization_members_on_organization_id  (organization_id)
#  index_organization_members_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :organization_member do
    organization
    user
    role { "member" }
  end
end
