require "rails_helper"

RSpec.describe PracticePolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:user) { nil }
  let(:record) { Practice.new }

  describe "without any user" do
    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
    it { is_expected.not_to be_select }
  end

  context "as a regular user with practice membership" do
    let(:user) { create(:user, organization: create(:organization)) }
    let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

    it { is_expected.to be_show }
    it { is_expected.to be_select }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  context "as a regular user without practice membership" do
    let(:user) { create(:user, organization: create(:organization)) }
    let(:record) { Practice.new(organization_id: create(:organization).id) }

    it { is_expected.not_to be_show }
    it { is_expected.not_to be_select }
  end

  context "as a practice admin/owner" do
    let(:user) { create(:user, organization: create(:organization)) }
    let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

    before do
      user.practice_memberships.where(practice_id: record.id).update_all(role: :admin)
    end

    it { is_expected.to be_show }
    it { is_expected.to be_edit }
    it { is_expected.to be_update }
    it { is_expected.not_to be_destroy }
  end

  context "as a system admin" do
    let(:user) { create_system_admin }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
    it { is_expected.to be_select }
  end
end
