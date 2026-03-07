require "rails_helper"

RSpec.describe CredentialPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:user) { nil }
  let(:record) { Credential.new }

  describe "without any user" do
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  context "as a regular user" do
    let(:user) { create(:user, organization: create(:organization)) }
    let(:record) { Credential.new(organization_id: user.organization_membership.organization_id) }

    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  context "as an organization admin" do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    before { user.create_organization_membership(organization: organization, role: :admin) }

    context "own organization's credential" do
      let(:record) { Credential.new(organization_id: organization.id) }

      it { is_expected.to be_create }
      it { is_expected.to be_update }
      it { is_expected.not_to be_destroy }
    end

    context "another organization's credential" do
      let(:record) { Credential.new(organization_id: create(:organization).id) }

      it { is_expected.not_to be_create }
      it { is_expected.not_to be_update }
    end
  end

  context "as a system admin" do
    let(:user) { create_system_admin }

    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end
end
