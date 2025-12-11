# == Schema Information
#
# Table name: practices
# Database name: primary
#
#  id              :uuid             not null, primary key
#  name            :string           not null
#  patients_count  :integer          default(0), not null
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
  belongs_to :organization, counter_cache: true
  has_many :members, dependent: :destroy, class_name: "PracticeMember"
  has_many :users, through: :members
  has_many :patients, dependent: :destroy

  validates :name, presence: true

  def first_owner
    members.find_by(role: "owner")&.user
  end
end
