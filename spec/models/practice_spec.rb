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
require "rails_helper"

RSpec.describe Practice, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
