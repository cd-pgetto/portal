require "test_helper"

describe OrganizationPolicy do
  def policy(user, record) = OrganizationPolicy.new(user, record)

  def org_admin
    user = create(:another_user)
    org = create(:organization)
    create(:organization_member, organization: org, user: user, role: :admin)
    [user.reload, org]
  end

  describe "#show?" do
    it "denies nil user" do
      refute policy(nil, Organization.new).show?
    end

    it "permits a regular user for their own org" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      assert policy(user.reload, org).show?
    end

    it "denies a regular user for another org" do
      user = create(:another_user)
      create(:organization_member, organization: create(:organization), user: user)
      refute policy(user.reload, Organization.new(id: create(:organization).id)).show?
    end

    it "permits an org admin for their own org" do
      user, org = org_admin
      assert policy(user, org).show?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, Organization.new).show?
    end
  end

  describe "#update?" do
    it "denies nil user" do
      refute policy(nil, Organization.new).update?
    end

    it "denies a regular user" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      refute policy(user.reload, org).update?
    end

    it "permits an org admin for their own org" do
      user, org = org_admin
      assert policy(user, org).update?
    end

    it "denies an org admin for another org" do
      user, _org = org_admin
      refute policy(user, Organization.new(id: create(:organization).id)).update?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, Organization.new).update?
    end
  end
end
