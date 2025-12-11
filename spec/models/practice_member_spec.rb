# == Schema Information
#
# Table name: practice_members
# Database name: primary
#
#  id          :uuid             not null, primary key
#  role        :enum             default("member"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  practice_id :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_practice_members_on_practice_id  (practice_id)
#  index_practice_members_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (practice_id => practices.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe PracticeMember, type: :model do
  subject { build(:practice_member, practice: build(:practice)) }

  describe "associations" do
    it { is_expected.to belong_to(:practice) }
    it { is_expected.to belong_to(:user) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:role)
        .with_values(owner: "owner", admin: "admin", member: "member", dentist: "dentist", hygienist: "hygienist",
          assistant: "assistant", inactive: "inactive")
        .backed_by_column_of_type(:enum)
    }

    it "has a default role of member" do
      member = PracticeMember.new
      expect(member.role).to eq("member")
    end

    it "allows setting role to owner" do
      member = build(:practice_member, role: "owner", practice: build(:practice))
      expect(member).to be_owner
    end

    it "allows setting role to admin" do
      member = build(:practice_member, role: "admin", practice: build(:practice))
      expect(member).to be_admin
    end

    it "allows setting role to member" do
      member = build(:practice_member, role: "member", practice: build(:practice))
      expect(member).to be_member
    end

    it "allows setting role to inactive" do
      member = build(:practice_member, role: "inactive", practice: build(:practice))
      expect(member).to be_inactive
    end
  end

  describe "validations" do
    context "when creating without practice" do
      subject { build(:practice_member, practice: nil) }

      it { is_expected.to be_invalid }
    end

    context "when creating without user" do
      subject { build(:practice_member, user: nil, practice: build(:practice)) }

      it { is_expected.to be_invalid }
    end
  end

  describe "database constraints" do
    it "requires practice_id" do
      member = create(:practice_member, practice: build(:practice, organization: build(:organization)),
        user: build(:user))

      expect {
        member.update_column(:practice_id, nil)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "requires user_id" do
      member = create(:practice_member, practice: build(:practice, organization: build(:organization)),
        user: build(:user))

      expect {
        member.update_column(:user_id, nil)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end
end
