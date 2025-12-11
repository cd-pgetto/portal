# == Schema Information
#
# Table name: organization_members
# Database name: primary
#
#  id              :uuid             not null, primary key
#  role            :enum             default("member"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid             not null
#  user_id         :uuid             not null
#
# Indexes
#
#  index_organization_members_on_organization_id  (organization_id)
#  index_organization_members_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe OrganizationMember, type: :model do
  subject { build(:organization_member, organization: build(:organization)) }

  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:user) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:role)
        .with_values(owner: "owner", admin: "admin", member: "member", inactive: "inactive")
        .backed_by_column_of_type(:enum)
    }

    it "has a default role of member" do
      member = OrganizationMember.new
      expect(member.role).to eq("member")
    end

    it "allows setting role to owner" do
      member = build(:organization_member, role: "owner")
      expect(member).to be_owner
    end

    it "allows setting role to admin" do
      member = build(:organization_member, role: "admin")
      expect(member).to be_admin
    end

    it "allows setting role to member" do
      member = build(:organization_member, role: "member")
      expect(member).to be_member
    end

    it "allows setting role to inactive" do
      member = build(:organization_member, role: "inactive")
      expect(member).to be_inactive
    end
  end

  describe "validations" do
    context "when creating without an organization" do
      subject { build(:organization_member, organization: nil) }

      it { is_expected.to be_invalid }
    end

    context "when creating without user" do
      subject { build(:organization_member, user: nil, organization: build(:organization)) }

      it { is_expected.to be_invalid }
    end
  end

  describe "database constraints" do
    it "requires organization_id" do
      organization_member = create(:organization_member, organization: build(:organization), user: build(:user))

      expect {
        organization_member.update_column(:organization_id, nil)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "requires user_id" do
      organization_member = create(:organization_member, organization: build(:organization), user: build(:user))

      expect {
        organization_member.update_column(:user_id, nil)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end
end
