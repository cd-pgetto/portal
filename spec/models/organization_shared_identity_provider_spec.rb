# == Schema Information
#
# Table name: organization_shared_identity_providers
# Database name: primary
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  identity_provider_id :uuid             not null
#  organization_id      :uuid             not null
#
# Indexes
#
#  idx_on_identity_provider_id_69c7c4049e                  (identity_provider_id)
#  idx_on_organization_id_5824626843                       (organization_id)
#  idx_on_organization_id_identity_provider_id_0f78e8471f  (organization_id,identity_provider_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (identity_provider_id => identity_providers.id)
#  fk_rails_...  (organization_id => organizations.id)
#
require "rails_helper"

RSpec.describe OrganizationSharedIdentityProvider, type: :model do
  subject { build(:organization_shared_identity_provider) }

  describe "associations" do
    it { is_expected.to belong_to(:organization).required }
    it { is_expected.to belong_to(:identity_provider).required }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:organization_id).scoped_to(:identity_provider_id).ignoring_case_sensitivity }
  end
end
