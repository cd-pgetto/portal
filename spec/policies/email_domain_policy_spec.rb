require "rails_helper"

RSpec.describe EmailDomainPolicy, type: :policy do
  subject { described_class }

  permissions :show? do
    context "without any user" do
      it { is_expected.not_to permit(nil, EmailDomain.new) }
    end

    context "as a regular user" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }

      context "own organization's domain" do
        it { is_expected.to permit(user, EmailDomain.new(organization_id: user.organization_membership.organization_id)) }
      end

      context "another organization's domain" do
        it { is_expected.not_to permit(user, EmailDomain.new(organization_id: create(:organization).id)) }
      end
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      context "own organization's domain" do
        it { is_expected.to permit(user, EmailDomain.new(organization_id: organization.id)) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, EmailDomain.new) }
    end
  end

  permissions :create?, :update? do
    context "without any user" do
      it { is_expected.not_to permit(nil, EmailDomain.new) }
    end

    context "as a regular user" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }

      it { is_expected.not_to permit(user, EmailDomain.new(organization_id: user.organization_membership.organization_id)) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      context "own organization's domain" do
        it { is_expected.to permit(user, EmailDomain.new(organization_id: organization.id)) }
      end

      context "another organization's domain" do
        it { is_expected.not_to permit(user, EmailDomain.new(organization_id: create(:organization).id)) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, EmailDomain.new) }
    end
  end

  permissions :destroy?, :index? do
    context "without any user" do
      it { is_expected.not_to permit(nil, EmailDomain.new) }
    end

    context "as a regular user" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }

      it { is_expected.not_to permit(user, EmailDomain.new(organization_id: user.organization_membership.organization_id)) }
    end

    context "as an organization admin" do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }

      before { user.create_organization_membership(organization: organization, role: :admin) }

      it { is_expected.not_to permit(user, EmailDomain.new(organization_id: organization.id)) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, EmailDomain.new) }
    end
  end
end
