# == Schema Information
#
# Table name: identity_providers
# Database name: primary
#
#  id            :uuid             not null, primary key
#  availability  :enum             default("shared"), not null
#  client_secret :string           not null
#  icon_url      :string           not null
#  name          :string           not null
#  strategy      :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :string           not null
#
# Indexes
#
#  index_identity_providers_on_strategy                (strategy) UNIQUE WHERE (availability = 'shared'::availability)
#  index_identity_providers_on_strategy_and_client_id  (strategy,client_id) UNIQUE
#
require "rails_helper"

RSpec.describe IdentityProvider, type: :model do
  subject { build(:identity_provider) }

  describe "associations" do
    it { is_expected.to have_many(:credentials).dependent(:destroy) }
    it { is_expected.to have_many(:organizations).through(:credentials) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:strategy) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:icon_url) }
    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_presence_of(:client_secret) }

    it { is_expected.to validate_uniqueness_of(:client_id).scoped_to(:strategy) }
    describe "when availability is shared" do
      subject { build(:identity_provider, availability: "shared") }
      it { is_expected.to validate_uniqueness_of(:strategy) }
    end

    describe "when availability is dedicated" do
      let!(:other_provider) { create(:identity_provider, strategy: "github", availability: "shared") }
      subject { build(:identity_provider, strategy: "github", availability: "dedicated") }
      it { is_expected.to be_valid }
    end
  end

  describe "enums" do
    it { is_expected.to respond_to(:availability) }
    it { is_expected.to respond_to(:shared?) }
    it { is_expected.to respond_to(:dedicated?) }
    it { expect(IdentityProvider.availabilities.keys).to contain_exactly("shared", "dedicated") }
    it { expect(IdentityProvider).to respond_to(:shared) }
    it { expect(IdentityProvider).to respond_to(:dedicated) }
  end
end
