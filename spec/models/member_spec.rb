# == Schema Information
#
# Table name: members
# Database name: primary
#
#  id                 :uuid             not null, primary key
#  business_unit_type :string           default("Organization"), not null
#  role               :enum             default("member"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  business_unit_id   :uuid             not null
#  user_id            :uuid             not null
#
# Indexes
#
#  index_members_on_business_unit_id_and_business_unit_type  (business_unit_id,business_unit_type)
#  index_members_on_user_id                                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (business_unit_id => organizations.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Member, type: :model do
  subject { build(:member, business_unit: create(:organization)) }

  describe "associations" do
    it { is_expected.to belong_to(:business_unit) }
    it { is_expected.to belong_to(:user) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:role)
        .with_values(owner: "owner", admin: "admin", member: "member", inactive: "inactive")
        .backed_by_column_of_type(:enum)
    }

    it "has a default role of member" do
      member = Member.new
      expect(member.role).to eq("member")
    end

    it "allows setting role to owner" do
      member = build(:member, role: "owner", business_unit: create(:organization))
      expect(member).to be_owner
    end

    it "allows setting role to admin" do
      member = build(:member, role: "admin", business_unit: create(:organization))
      expect(member).to be_admin
    end

    it "allows setting role to member" do
      member = build(:member, role: "member", business_unit: create(:organization))
      expect(member).to be_member
    end

    it "allows setting role to inactive" do
      member = build(:member, role: "inactive", business_unit: create(:organization))
      expect(member).to be_inactive
    end
  end

  describe "validations" do
    context "when creating without business_unit" do
      subject { build(:member, business_unit: nil) }

      it { is_expected.to be_invalid }
    end

    context "when creating without user" do
      subject { build(:member, user: nil, business_unit: create(:organization)) }

      it { is_expected.to be_invalid }
    end
  end

  describe "database constraints" do
    it "requires business_unit_id" do
      member = build(:member, business_unit: create(:organization), user: create(:user))
      member.save!

      expect {
        member.update_column(:business_unit_id, nil)
        member.reload
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "requires user_id" do
      member = build(:member, business_unit: create(:organization), user: create(:user))
      member.save!

      expect {
        member.update_column(:user_id, nil)
        member.reload
      }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end
end
