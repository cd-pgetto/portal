require "rails_helper"

RSpec.describe PracticeMemberPolicy, type: :policy do
  subject { described_class }

  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:target_user) { create(:another_user, organization: organization, practices: [practice]) }
  let(:record) { target_user.practice_memberships.find_by(practice: practice) }

  permissions :create?, :update?, :destroy? do
    context "without any user" do
      it { is_expected.not_to permit(nil, record) }
    end

    context "as a practice member (not admin/owner)" do
      let(:user) { create(:dr_sue, organization: organization, practices: [practice]) }
      it { is_expected.not_to permit(user, record) }
    end

    context "as a practice admin" do
      let(:user) { create(:user, organization: organization, practices: [practice]) }
      before { user.practice_memberships.find_by(practice: practice).update!(role: :admin) }
      it { is_expected.to permit(user, record) }
    end

    context "as a practice owner" do
      let(:user) { create(:user, organization: organization, practices: [practice]) }
      before { user.practice_memberships.find_by(practice: practice).update!(role: :owner) }
      it { is_expected.to permit(user, record) }
    end

    context "as an admin of a different practice" do
      let(:other_practice) { create(:practice, organization: organization) }
      let(:user) { create(:dr_sue, organization: organization, practices: [other_practice]) }
      before { user.practice_memberships.find_by(practice: other_practice).update!(role: :admin) }
      it { is_expected.not_to permit(user, record) }
    end
  end
end
