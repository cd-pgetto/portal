require "rails_helper"

RSpec.describe IdentityProviderPolicy, type: :policy do
  subject { described_class }

  permissions :index? do
    context "without any user" do
      it { is_expected.not_to permit(nil, IdentityProvider.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user, organization: create(:organization)) }

      it { is_expected.not_to permit(user, IdentityProvider.new) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      it { is_expected.not_to permit(user, IdentityProvider.new) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, IdentityProvider.new) }
    end
  end

  permissions :show?, :create?, :update? do
    context "without any user" do
      it { is_expected.not_to permit(nil, IdentityProvider.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user, organization: create(:organization)) }

      it { is_expected.not_to permit(user, IdentityProvider.new) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      context "with a dedicated identity provider in own organization" do
        let(:record) do
          ip = IdentityProvider.new
          allow(ip).to receive(:dedicated?).and_return(true)
          allow(ip).to receive(:organization_ids).and_return([organization.id])
          ip
        end

        it { is_expected.to permit(user, record) }
      end

      context "with a non-dedicated identity provider" do
        let(:record) do
          ip = IdentityProvider.new
          allow(ip).to receive(:dedicated?).and_return(false)
          ip
        end

        it { is_expected.not_to permit(user, record) }
      end

      context "with a dedicated identity provider in another organization" do
        let(:record) do
          ip = IdentityProvider.new
          allow(ip).to receive(:dedicated?).and_return(true)
          allow(ip).to receive(:organization_ids).and_return([create(:organization).id])
          ip
        end

        it { is_expected.not_to permit(user, record) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, IdentityProvider.new) }
    end
  end

  permissions :destroy? do
    context "without any user" do
      it { is_expected.not_to permit(nil, IdentityProvider.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user, organization: create(:organization)) }

      it { is_expected.not_to permit(user, IdentityProvider.new) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      it { is_expected.not_to permit(user, IdentityProvider.new) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, IdentityProvider.new) }
    end
  end
end
