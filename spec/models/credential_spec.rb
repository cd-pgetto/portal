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
