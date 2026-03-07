require "rails_helper"

RSpec.describe OrganizationPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:user) { nil }
  let(:record) { Organization.new }

  describe "without any user" do
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
    it { is_expected.not_to be_index }
  end

  context "as a regular user" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }

    context "own organization" do
      let(:record) { Organization.new(id: user.organization_membership.organization_id) }

      it { is_expected.to be_show }
      it { is_expected.not_to be_create }
      it { is_expected.not_to be_update }
      it { is_expected.not_to be_destroy }
    end

    context "another organization" do
      let(:record) { Organization.new(id: create(:organization).id) }

      it { is_expected.not_to be_show }
    end
  end

  context "as an organization admin" do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    before { user.create_organization_membership(organization: organization, role: :admin) }

    context "own organization" do
      let(:record) { Organization.new(id: organization.id) }

      it { is_expected.to be_show }
      it { is_expected.to be_update }
      it { is_expected.not_to be_create }
      it { is_expected.not_to be_destroy }
    end

    context "another organization" do
      let(:record) { Organization.new(id: create(:organization).id) }

      it { is_expected.not_to be_update }
    end
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
