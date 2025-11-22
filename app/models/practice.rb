# == Schema Information
#
# Table name: practices
# Database name: primary
#
#  id              :uuid             not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid             not null
#
# Indexes
#
#  index_practices_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class Practice < ApplicationRecord
  belongs_to :organization
  has_many :members, as: :business_unit, dependent: :destroy
  has_many :users, through: :members

  validates :name, presence: true
end
