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
FactoryBot.define do
  factory :practice do
    name { "MyString" }
    organization { nil }

    factory :practice_with_org do
      name { "West Lake" }
      organization
    end
  end
end
