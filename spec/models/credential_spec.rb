# == Schema Information
#
# Table name: credentials
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  identity_provider_id :uuid             not null
#  organization_id      :uuid             not null
#
# Indexes
#
#  index_credentials_on_identity_provider_id                      (identity_provider_id)
#  index_credentials_on_organization_id                           (organization_id)
#  index_credentials_on_organization_id_and_identity_provider_id  (organization_id,identity_provider_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (identity_provider_id => identity_providers.id)
#  fk_rails_...  (organization_id => organizations.id)
#
require "rails_helper"

RSpec.describe Credential, type: :model do
  subject { build(:credential) }

  describe "associations" do
    it { is_expected.to belong_to(:organization).required }
    it { is_expected.to belong_to(:identity_provider).required }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:organization_id).scoped_to(:identity_provider_id).ignoring_case_sensitivity }
  end
end
