require "rails_helper"

RSpec.describe OrganizationPolicy, type: :policy do
  subject { described_class }

  permissions :show? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Organization.new) }
    end

    context "as a regular user" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }

      context "own organization" do
        it { is_expected.to permit(user, organization) }
      end

      context "another organization" do
        it { is_expected.not_to permit(user, Organization.new(id: create(:organization).id)) }
      end
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      context "own organization" do
        it { is_expected.to permit(user, organization) }
      end

      context "another organization" do
        it { is_expected.not_to permit(user, Organization.new(id: create(:organization).id)) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Organization.new) }
    end
  end

  permissions :update? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Organization.new) }
    end

    context "as a regular user" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }

      it { is_expected.not_to permit(user, organization) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      context "own organization" do
        it { is_expected.to permit(user, organization) }
      end

      context "another organization" do
        it { is_expected.not_to permit(user, Organization.new(id: create(:organization).id)) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Organization.new) }
    end
  end

  permissions :index?, :create?, :destroy? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Organization.new) }
    end

    context "as a regular user" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }

      it { is_expected.not_to permit(user, Organization.new) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      it { is_expected.not_to permit(user, organization) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Organization.new) }
    end
  end
end
