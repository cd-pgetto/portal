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

RSpec.describe IdentityProvider, type: :model do
  describe ".available_strategies" do
    subject(:strategies) { described_class.available_strategies }

    it "returns an array of strings" do
      expect(strategies).to be_an(Array)
      expect(strategies).to all(be_a(String))
    end

    it "returns sorted results" do
      expect(strategies).to eq(strategies.sort)
    end

    it "excludes nil values" do
      expect(strategies).to all(be_present)
    end

    it "includes google_oauth2" do
      expect(strategies).to include("google_oauth2")
    end
  end
end

RSpec.describe IdentityProvider::Shared, type: :model do
  subject { build(:identity_provider) }

  describe "associations" do
    it { is_expected.to have_many(:organization_shared_identity_providers).dependent(:destroy) }
    it { is_expected.to have_many(:organizations).through(:organization_shared_identity_providers) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:strategy) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:icon_url) }

    it "prevents two shared providers with the same strategy" do
      create(:identity_provider, strategy: "github")
      duplicate = build(:identity_provider, strategy: "github")
      expect(duplicate).not_to be_valid
    end
  end

  describe "#shared? and #dedicated?" do
    it "is shared" do
      expect(subject.shared?).to be true
      expect(subject.dedicated?).to be false
    end
  end
end
