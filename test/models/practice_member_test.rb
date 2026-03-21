require "test_helper"

describe PracticeMember do
  describe "enums" do
    it "has the expected role values" do
      expected = %w[owner admin member dentist hygienist assistant]
      assert_equal expected.to_set, PracticeMember.roles.keys.to_set
    end

    it "has a default role of member" do
      assert_equal "member", PracticeMember.new.role
    end

    it "allows setting role to owner" do
      assert build(:practice_member, role: "owner", practice: build(:practice)).owner?
    end

    it "allows setting role to admin" do
      assert build(:practice_member, role: "admin", practice: build(:practice)).admin?
    end

    it "allows setting role to member" do
      assert build(:practice_member, role: "member", practice: build(:practice)).member?
    end

    it "allows setting role to assistant" do
      assert build(:practice_member, role: "assistant", practice: build(:practice)).assistant?
    end
  end

  describe "PRIVILEGED_ROLES" do
    it "contains owner and admin" do
      assert_equal ["owner", "admin"].to_set, PracticeMember::PRIVILEGED_ROLES.to_set
    end
  end

  describe "REGULAR_ROLES" do
    it "contains non-privileged roles" do
      assert_equal ["member", "dentist", "hygienist", "assistant"].to_set,
        PracticeMember::REGULAR_ROLES.to_set
    end

    it "does not overlap with PRIVILEGED_ROLES" do
      assert_empty PracticeMember::REGULAR_ROLES & PracticeMember::PRIVILEGED_ROLES
    end

    it "covers all roles together with PRIVILEGED_ROLES" do
      assert_equal PracticeMember.roles.keys.to_set,
        (PracticeMember::REGULAR_ROLES + PracticeMember::PRIVILEGED_ROLES).to_set
    end
  end

  describe "scopes" do
    # alice_member (active) and bob_dentist (active) come from fixtures.
    # An inactive member is created inline.
    let(:inactive_member) do
      create(:practice_member,
        practice: practices(:acme_dental),
        user: create(:another_user, organization: organizations(:acme)),
        active: false)
    end

    it ".active returns only active members" do
      inactive_member # force creation
      assert_includes PracticeMember.active, practice_members(:alice_member)
      refute_includes PracticeMember.active, inactive_member
    end

    it ".inactive returns only inactive members" do
      assert_includes PracticeMember.inactive, inactive_member
      refute_includes PracticeMember.inactive, practice_members(:alice_member)
    end

    it ".admin_or_owner returns active admin and owner members" do
      practice_members(:alice_member).update!(role: :admin)
      assert_includes PracticeMember.admin_or_owner, practice_members(:alice_member)
      refute_includes PracticeMember.admin_or_owner, inactive_member
    end

    it ".admin_or_owner_in scopes to a specific practice" do
      other_practice = create(:practice, organization: organizations(:acme))
      practice_members(:alice_member).update!(role: :owner)
      assert_includes PracticeMember.admin_or_owner_in(practices(:acme_dental).id),
        practice_members(:alice_member)
      assert_empty PracticeMember.admin_or_owner_in(other_practice.id)
    end
  end

  describe "validations" do
    describe "when the same user already has that role in the practice" do
      let(:practice) { create(:practice, organization: create(:organization)) }
      let(:user) { create(:another_user) }

      before { create(:practice_member, practice: practice, user: user, role: :dentist) }

      it "is invalid" do
        duplicate = build(:practice_member, practice: practice, user: user, role: :dentist)
        refute duplicate.valid?
        assert duplicate.errors[:user_id].present?
      end

      it "allows the same user to have a different role" do
        assert build(:practice_member, practice: practice, user: user, role: :admin).valid?
      end
    end

    it "is invalid without a practice" do
      refute build(:practice_member, practice: nil).valid?
    end

    it "is invalid without a user" do
      refute build(:practice_member, user: nil, practice: build(:practice)).valid?
    end
  end

  describe "database constraints" do
    it "requires practice_id" do
      member = create(:practice_member,
        practice: create(:practice_with_org),
        user: create(:another_user))
      assert_raises(ActiveRecord::NotNullViolation) { member.update_column(:practice_id, nil) }
    end

    it "requires user_id" do
      member = create(:practice_member,
        practice: create(:practice_with_org),
        user: create(:another_user))
      assert_raises(ActiveRecord::NotNullViolation) { member.update_column(:user_id, nil) }
    end
  end
end
