require "rails_helper"

RSpec.describe CredentialPolicy, type: :policy do
  subject { described_class }

  permissions :create?, :update? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Credential.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user, organization: create(:organization)) }

      it { is_expected.not_to permit(user, Credential.new(organization_id: user.organization_membership.organization_id)) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      context "own organization's credential" do
        it { is_expected.to permit(user, Credential.new(organization_id: organization.id)) }
      end

      context "another organization's credential" do
        it { is_expected.not_to permit(user, Credential.new(organization_id: create(:organization).id)) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Credential.new) }
    end
  end

  permissions :destroy? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Credential.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user, organization: create(:organization)) }

      it { is_expected.not_to permit(user, Credential.new(organization_id: user.organization_membership.organization_id)) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      it { is_expected.not_to permit(user, Credential.new(organization_id: organization.id)) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Credential.new) }
    end
  end
end
