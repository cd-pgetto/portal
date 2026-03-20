require "rails_helper"

RSpec.describe PracticePolicy, type: :policy do
  subject { described_class }

  permissions :index? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Practice.new) }
    end

    context "as a regular user with practice membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      it { is_expected.to permit(user, record) }
    end

    context "as a regular user without practice membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { Practice.new(organization_id: create(:organization).id) }

      it { is_expected.not_to permit(user, record) }
    end

    context "as a user with only an inactive membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      before { user.all_practice_memberships.where(practice_id: record.id).update_all(active: false) }

      it { is_expected.not_to permit(user, record) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Practice.new) }
    end
  end

  permissions :show? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Practice.new) }
    end

    context "as a regular user with practice membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      it { is_expected.to permit(user, record) }
    end

    context "as a regular user without practice membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { Practice.new(organization_id: create(:organization).id) }

      it { is_expected.not_to permit(user, record) }
    end

    context "as a practice admin/owner" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      before { user.practice_memberships.where(practice_id: record.id).update_all(role: :admin) }

      it { is_expected.to permit(user, record) }
    end

    context "as a user with only an inactive membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      before { user.all_practice_memberships.where(practice_id: record.id).update_all(active: false) }

      it { is_expected.not_to permit(user, record) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Practice.new) }
    end
  end

  permissions :create? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Practice.new) }
    end

    context "as a regular user with practice membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      it { is_expected.not_to permit(user, record) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Practice.new) }
    end
  end

  permissions :edit?, :update? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Practice.new) }
    end

    context "as a regular user with practice membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      it { is_expected.not_to permit(user, record) }
    end

    context "as a practice admin/owner" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      before { user.practice_memberships.where(practice_id: record.id).update_all(role: :admin) }

      it { is_expected.to permit(user, record) }
    end

    context "as a user with only an inactive admin membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      before { user.all_practice_memberships.where(practice_id: record.id).update_all(role: :admin, active: false) }

      it { is_expected.not_to permit(user, record) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Practice.new) }
    end
  end

  permissions :destroy? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Practice.new) }
    end

    context "as a regular user with practice membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      it { is_expected.not_to permit(user, record) }
    end

    context "as a practice admin/owner" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      before { user.practice_memberships.where(practice_id: record.id).update_all(role: :admin) }

      it { is_expected.not_to permit(user, record) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Practice.new) }
    end
  end

  permissions :select? do
    context "without any user" do
      it { is_expected.not_to permit(nil, Practice.new) }
    end

    context "as a regular user with practice membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }

      it { is_expected.to permit(user, record) }
    end

    context "as a regular user without practice membership" do
      let(:user) { create(:user, organization: create(:organization)) }
      let(:record) { Practice.new(organization_id: create(:organization).id) }

      it { is_expected.not_to permit(user, record) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, Practice.new) }
    end
  end

  describe described_class::Scope do
    subject(:resolved) { described_class.new(user, Practice.all).resolve }

    let!(:practice) { create(:practice_with_org) }
    let!(:other_practice) { create(:practice_with_org) }

    context "without any user" do
      let(:user) { nil }

      it { is_expected.to be_empty }
    end

    context "as a practice member" do
      let(:user) { create(:user) }

      before { create(:practice_member, practice: practice, user: user) }

      it { is_expected.to contain_exactly(practice) }
    end

    context "as a non-member" do
      let(:user) { create(:another_user) }

      it { is_expected.to be_empty }
    end

    context "as a user with only an inactive membership" do
      let(:user) { create(:user) }

      before do
        create(:practice_member, practice: practice, user: user, active: false)
      end

      it { is_expected.not_to include(practice) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to include(practice, other_practice) }
    end
  end
end
