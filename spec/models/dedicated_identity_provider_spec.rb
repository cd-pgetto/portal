# == Schema Information
#
# Table name: identity_providers
# Database name: primary
#
#  id              :uuid             not null, primary key
#  client_secret   :text             default("")
#  icon_url        :string           not null
#  name            :string           not null
#  okta_domain     :string
#  strategy        :string           not null
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :text             default("")
#  organization_id :uuid
#
# Indexes
#
#  index_identity_providers_on_organization_id  (organization_id) UNIQUE WHERE (organization_id IS NOT NULL)
#  index_identity_providers_on_strategy         (strategy) UNIQUE WHERE (organization_id IS NULL)
#  index_identity_providers_on_type             (type)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
require "rails_helper"

RSpec.describe DedicatedIdentityProvider, type: :model do
  subject { build(:okta_identity_provider) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:organization) }
    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_presence_of(:client_secret) }
  end

  describe "#dedicated?" do
    it { is_expected.to be_dedicated }
    it { is_expected.not_to be_shared }
  end

  describe ".class_for_strategy" do
    it "returns the class name for a known strategy" do
      expect(described_class.class_for_strategy("okta")).to eq("OktaIdentityProvider")
    end

    it "returns nil for an unknown strategy" do
      expect(described_class.class_for_strategy("unknown")).to be_nil
    end
  end

  describe ".dedicated_strategies" do
    it "includes okta" do
      expect(described_class.dedicated_strategies).to include("okta")
    end
  end
end
