require "rails_helper"

RSpec.describe IdentityProviderPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:user) { nil }
  let(:record) { IdentityProvider.new }

  describe "without any user" do
    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  context "as a regular user" do
    let(:user) { create(:user, organization: create(:organization)) }

    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  context "as an organization admin" do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    before { user.create_organization_membership(organization: organization, role: :admin) }

    [:create, :update].each do |action|
      context "with a dedicated identity provider in own organization" do
        let(:record) do
          ip = IdentityProvider.new
          allow(ip).to receive(:dedicated?).and_return(true)
          allow(ip).to receive(:organization_ids).and_return([organization.id])
          ip
        end

        it { expect(policy.public_send(:"#{action}?")).to be true }
      end

      context "with a non-dedicated identity provider" do
        let(:record) do
          ip = IdentityProvider.new
          allow(ip).to receive(:dedicated?).and_return(false)
          ip
        end

        it { expect(policy.public_send(:"#{action}?")).to be false }
      end

      context "with a dedicated identity provider in another organization" do
        let(:record) do
          ip = IdentityProvider.new
          allow(ip).to receive(:dedicated?).and_return(true)
          allow(ip).to receive(:organization_ids).and_return([create(:organization).id])
          ip
        end

        it { expect(policy.public_send(:"#{action}?")).to be false }
      end
    end

    it { is_expected.not_to be_destroy }
    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
  end

  context "as a system admin" do
    let(:user) { create_system_admin }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end
end
