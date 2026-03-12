require "rails_helper"

RSpec.describe DashboardPolicy, type: :policy do
  subject { described_class }

  permissions :show? do
    context "without any user" do
      it { is_expected.not_to permit(nil, :dashboard) }
    end

    context "as a regular user" do
      let(:user) { create(:user) }

      it { is_expected.not_to permit(user, :dashboard) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, :dashboard) }
    end
  end
end
