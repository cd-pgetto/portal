require "rails_helper"

RSpec.describe PatientPolicy, type: :policy do
  subject { described_class }

  let(:practice) { create(:practice_with_org) }
  let(:patient) { create(:patient, practice: practice) }

  permissions :index?, :show?, :create?, :update? do
    context "without any user" do
      it { is_expected.not_to permit(nil, patient) }
    end

    context "as a practice member" do
      let(:user) { create(:user) }

      before { create(:practice_member, practice: practice, user: user) }

      it { is_expected.to permit(user, patient) }
    end

    context "as a non-member" do
      let(:user) { create(:another_user) }

      it { is_expected.not_to permit(user, patient) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, patient) }
    end
  end

  permissions :destroy? do
    context "without any user" do
      it { is_expected.not_to permit(nil, patient) }
    end

    context "as a practice member" do
      let(:user) { create(:user) }

      before { create(:practice_member, practice: practice, user: user) }

      it { is_expected.not_to permit(user, patient) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, patient) }
    end
  end

  describe described_class::Scope do
    subject(:resolved) { described_class.new(user, Patient.all).resolve }

    let(:practice) { create(:practice_with_org) }
    let(:other_practice) { create(:practice_with_org) }
    let!(:own_patient) { create(:patient, practice: practice) }
    let!(:other_patient) { create(:patient, practice: other_practice) }

    context "without any user" do
      let(:user) { nil }

      it { is_expected.to be_empty }
    end

    context "as a practice member" do
      let(:user) { create(:user) }

      before { create(:practice_member, practice: practice, user: user) }

      it { is_expected.to contain_exactly(own_patient) }
    end

    context "as a non-member" do
      let(:user) { create(:another_user) }

      it { is_expected.to be_empty }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to include(own_patient, other_patient) }
    end
  end
end
