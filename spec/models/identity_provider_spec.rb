require "rails_helper"

RSpec.describe IdentityProvider, type: :model do
  subject { build(:identity_provider) }

  describe "associations" do
    it { is_expected.to have_many(:organization_shared_identity_providers).dependent(:destroy) }
    it { is_expected.to have_many(:organizations).through(:organization_shared_identity_providers) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:strategy) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:icon_url) }
    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_presence_of(:client_secret) }

    it { is_expected.to validate_uniqueness_of(:client_id).scoped_to(:strategy) }

    it "prevents two shared providers with the same strategy" do
      create(:identity_provider, strategy: "github")
      duplicate = build(:identity_provider, strategy: "github")
      expect(duplicate).not_to be_valid
    end
  end

  describe "#shared? and #dedicated?" do
    it "is shared by default" do
      expect(subject.shared?).to be true
      expect(subject.dedicated?).to be false
    end
  end
end
