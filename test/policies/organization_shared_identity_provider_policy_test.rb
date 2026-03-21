require "test_helper"

describe OrganizationSharedIdentityProviderPolicy do
  def policy(user, record) = OrganizationSharedIdentityProviderPolicy.new(user, record)

  def org_admin
    user = create(:another_user)
    org = create(:organization)
    create(:organization_member, organization: org, user: user, role: :admin)
    [user.reload, org]
  end

  describe "#create? and #update?" do
    it "denies nil user" do
      refute policy(nil, OrganizationSharedIdentityProvider.new).create?
      refute policy(nil, OrganizationSharedIdentityProvider.new).update?
    end

    it "denies a regular user for their own org" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      refute policy(user.reload, OrganizationSharedIdentityProvider.new(organization_id: org.id)).create?
    end

    it "permits an org admin for their own org" do
      user, org = org_admin
      record = OrganizationSharedIdentityProvider.new(organization_id: org.id)
      assert policy(user, record).create?
      assert policy(user, record).update?
    end

    it "denies an org admin for another org" do
      user, _org = org_admin
      record = OrganizationSharedIdentityProvider.new(organization_id: create(:organization).id)
      refute policy(user, record).create?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, OrganizationSharedIdentityProvider.new).create?
      assert policy(create_system_admin, OrganizationSharedIdentityProvider.new).update?
    end
  end

  describe "#destroy?" do
    it "denies nil user" do
      refute policy(nil, OrganizationSharedIdentityProvider.new).destroy?
    end

    it "denies a regular user" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      refute policy(user.reload, OrganizationSharedIdentityProvider.new(organization_id: org.id)).destroy?
    end

    it "denies an org admin" do
      user, org = org_admin
      refute policy(user, OrganizationSharedIdentityProvider.new(organization_id: org.id)).destroy?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, OrganizationSharedIdentityProvider.new).destroy?
    end
  end
end
