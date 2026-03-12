require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  subject { described_class }

  permissions :create? do
    context "without any user" do
      it { is_expected.to permit(nil, User.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user) }

      it { is_expected.not_to permit(user, User.new) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, User.new) }
    end
  end

  permissions :show?, :edit?, :update? do
    context "without any user" do
      it { is_expected.not_to permit(nil, User.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user) }

      context "own record" do
        it { is_expected.to permit(user, user) }
      end

      context "another user's record" do
        it { is_expected.not_to permit(user, create(:another_user)) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, User.new) }
    end
  end

  permissions :destroy? do
    context "without any user" do
      it { is_expected.not_to permit(nil, User.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user) }

      context "own record" do
        it { is_expected.not_to permit(user, user) }
      end

      context "another user's record" do
        it { is_expected.not_to permit(user, create(:another_user)) }
      end
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, User.new) }
    end
  end

  permissions :index? do
    context "without any user" do
      it { is_expected.not_to permit(nil, User.new) }
    end

    context "as a regular user" do
      let(:user) { create(:user) }

      it { is_expected.not_to permit(user, User.new) }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to permit(user, User.new) }
    end
  end

  describe described_class::Scope do
    subject(:resolved) { described_class.new(user, User.all).resolve }

    let!(:user_a) { create(:user) }
    let!(:user_b) { create(:another_user) }

    context "without any user" do
      let(:user) { nil }

      it { is_expected.to be_empty }
    end

    context "as a regular user" do
      let(:user) { create(:another_user) }

      it { is_expected.to be_empty }
    end

    context "as a system admin" do
      let(:user) { create_system_admin }

      it { is_expected.to include(user_a, user_b) }
    end
  end
end
