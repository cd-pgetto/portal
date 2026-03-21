require "test_helper"

describe OrganizationMember do
  describe "enums" do
    it "has the expected role values" do
      assert_equal %w[owner admin member inactive].to_set, OrganizationMember.roles.keys.to_set
    end

    it "has a default role of member" do
      assert_equal "member", OrganizationMember.new.role
    end

    it "allows setting role to owner" do
      assert build(:organization_member, role: "owner").owner?
    end

    it "allows setting role to admin" do
      assert build(:organization_member, role: "admin").admin?
    end

    it "allows setting role to member" do
      assert build(:organization_member, role: "member").member?
    end

    it "allows setting role to inactive" do
      assert build(:organization_member, role: "inactive").inactive?
    end
  end

  describe "validations" do
    it "is invalid without an organization" do
      refute build(:organization_member, organization: nil).valid?
    end

    it "is invalid without a user" do
      refute build(:organization_member, user: nil, organization: build(:organization)).valid?
    end
  end

  describe "database constraints" do
    it "requires organization_id" do
      member = create(:organization_member, organization: create(:organization), user: create(:another_user))
      assert_raises(ActiveRecord::NotNullViolation) { member.update_column(:organization_id, nil) }
    end

    it "requires user_id" do
      member = create(:organization_member, organization: create(:organization), user: create(:another_user))
      assert_raises(ActiveRecord::NotNullViolation) { member.update_column(:user_id, nil) }
    end
  end
end
