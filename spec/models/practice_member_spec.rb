# == Schema Information
#
# Table name: practice_members
# Database name: primary
#
#  id          :uuid             not null, primary key
#  active      :boolean          default(TRUE), not null
#  role        :enum             default("member"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  practice_id :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_practice_members_on_practice_id                       (practice_id)
#  index_practice_members_on_user_id                           (user_id)
#  index_practice_members_on_user_id_and_practice_id_and_role  (user_id,practice_id,role) UNIQUE
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
          assistant: "assistant")
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

    it "allows setting role to assistant" do
      member = build(:practice_member, role: "assistant", practice: build(:practice))
      expect(member).to be_assistant
    end
  end

  describe "scopes" do
    let(:organization) { create(:organization) }
    let(:practice) { create(:practice, organization: organization) }
    let!(:active_member) { create(:practice_member, practice: practice, user: create(:user, organization: organization)) }
    let!(:inactive_member) { create(:practice_member, practice: practice, user: create(:another_user, organization: organization), active: false) }

    it ".active returns only active members" do
      expect(PracticeMember.active).to include(active_member)
      expect(PracticeMember.active).not_to include(inactive_member)
    end

    it ".inactive returns only inactive members" do
      expect(PracticeMember.inactive).to include(inactive_member)
      expect(PracticeMember.inactive).not_to include(active_member)
    end

    it ".admin_or_owner returns active admin and owner members" do
      active_member.update!(role: :admin)
      expect(PracticeMember.admin_or_owner).to include(active_member)
      expect(PracticeMember.admin_or_owner).not_to include(inactive_member)
    end

    it ".admin_or_owner_in scopes to a specific practice" do
      active_member.update!(role: :owner)
      other_practice = create(:practice, organization: organization)
      expect(PracticeMember.admin_or_owner_in(practice.id)).to include(active_member)
      expect(PracticeMember.admin_or_owner_in(other_practice.id)).to be_empty
    end
  end

  describe "validations" do
    context "when the same user already has that role in the practice" do
      let(:practice) { create(:practice, organization: create(:organization)) }
      let(:user) { create(:user) }

      before { create(:practice_member, practice: practice, user: user, role: :dentist) }

      it "is invalid" do
        duplicate = build(:practice_member, practice: practice, user: user, role: :dentist)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to be_present
      end

      it "allows the same user to have a different role" do
        second_role = build(:practice_member, practice: practice, user: user, role: :admin)
        expect(second_role).to be_valid
      end
    end

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
