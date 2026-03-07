require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { User.new }
  let(:user) { nil }

  describe "without any user" do
    it { is_expected.to be_create }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_edit }
    it { is_expected.not_to be_destroy }
    it { is_expected.not_to be_index }
  end

  context "as a regular user" do
    let(:user) { create(:user) }

    context "own record" do
      let(:record) { user }

      it { is_expected.to be_show }
      it { is_expected.to be_update }
      it { is_expected.to be_edit }
      it { is_expected.not_to be_create }
      it { is_expected.not_to be_destroy }
      it { is_expected.not_to be_index }
    end

    context "another user's record" do
      let(:record) { create(:another_user) }

      it { is_expected.not_to be_show }
      it { is_expected.not_to be_update }
      it { is_expected.not_to be_destroy }
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
