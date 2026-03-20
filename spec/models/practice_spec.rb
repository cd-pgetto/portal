# == Schema Information
#
# Table name: practices
# Database name: primary
#
#  id              :uuid             not null, primary key
#  name            :string           not null
#  patients_count  :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid             not null
#
# Indexes
#
#  index_practices_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
require "rails_helper"

RSpec.describe Practice, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:invitations).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "#first_owner" do
    let(:organization) { create(:organization) }
    let(:practice) { create(:practice, organization: organization) }
    let(:owner) { create(:user, organization: organization) }

    context "when there is an active owner" do
      before { create(:practice_member, practice: practice, user: owner, role: :owner) }

      it "returns the owner" do
        expect(practice.first_owner).to eq(owner)
      end
    end

    context "when the owner's membership is inactive" do
      before { create(:practice_member, practice: practice, user: owner, role: :owner, active: false) }

      it "returns nil" do
        expect(practice.first_owner).to be_nil
      end
    end

    context "when there is no owner" do
      it "returns nil" do
        expect(practice.first_owner).to be_nil
      end
    end
  end
end
