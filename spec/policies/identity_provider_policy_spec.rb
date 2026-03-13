require "rails_helper"

RSpec.describe IdentityProviderPolicy, type: :policy do
  subject { described_class }

  permissions :index? do
    context "without any user" do
      it { is_expected.not_to permit(nil, IdentityProvider::Shared.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user, organization: create(:organization)) }

      it { is_expected.not_to permit(user, IdentityProvider::Shared.new) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      it { is_expected.not_to permit(user, IdentityProvider::Shared.new) }

      context "with a dedicated identity provider in own organization" do
        let(:record) { create(:okta_identity_provider, organization: organization) }

        it { is_expected.not_to permit(user, record) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, IdentityProvider::Shared.new) }
    end
  end

  permissions :show?, :create?, :update? do
    context "without any user" do
      it { is_expected.not_to permit(nil, IdentityProvider::Shared.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user, organization: create(:organization)) }

      it { is_expected.not_to permit(user, IdentityProvider::Shared.new) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      context "with a dedicated identity provider in own organization" do
        let(:record) { create(:okta_identity_provider, organization: organization) }

        it { is_expected.to permit(user, record) }
      end

      context "with a shared identity provider" do
        let(:record) { IdentityProvider::Shared.new }

        it { is_expected.not_to permit(user, record) }
      end

      context "with a dedicated identity provider in another organization" do
        let(:record) { create(:okta_identity_provider, organization: create(:organization)) }

        it { is_expected.not_to permit(user, record) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, IdentityProvider::Shared.new) }
    end
  end

  permissions :destroy? do
    context "without any user" do
      it { is_expected.not_to permit(nil, IdentityProvider::Shared.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user, organization: create(:organization)) }

      it { is_expected.not_to permit(user, IdentityProvider::Shared.new) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      it { is_expected.not_to permit(user, IdentityProvider::Shared.new) }

      context "with a dedicated identity provider in own organization" do
        let(:record) { create(:okta_identity_provider, organization: organization) }

        it { is_expected.not_to permit(user, record) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, IdentityProvider::Shared.new) }
    end
  end

  describe described_class::Scope do
    subject(:resolved) { described_class.new(user, IdentityProvider.all).resolve }

    let!(:provider_a) { create(:identity_provider) }
    let!(:provider_b) { create(:google_identity_provider) }

    context "without any user" do
      let(:user) { nil }

      it { is_expected.to be_empty }
    end

    context "as a regular user" do
      let(:user) { create(:user, organization: create(:organization)) }

      it { is_expected.to be_empty }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      it { is_expected.to be_empty }

      context "with a dedicated identity provider in own organization" do
        let!(:dedicated_provider) { create(:okta_identity_provider, organization: organization) }

        it { is_expected.to be_empty }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to include(provider_a, provider_b) }
    end
  end
end
