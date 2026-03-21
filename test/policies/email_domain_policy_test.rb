require "test_helper"

describe EmailDomainPolicy do
  def policy(user, record) = EmailDomainPolicy.new(user, record)

  def org_admin
    user = create(:another_user)
    org = create(:organization)
    create(:organization_member, organization: org, user: user, role: :admin)
    [user.reload, org]
  end

  describe "#show?" do
    it "denies nil user" do
      refute policy(nil, EmailDomain.new).show?
    end

    it "permits a regular user for their own org's domain" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      assert policy(user.reload, EmailDomain.new(organization_id: org.id)).show?
    end

    it "denies a regular user for another org's domain" do
      user = create(:another_user)
      create(:organization_member, organization: create(:organization), user: user)
      refute policy(user.reload, EmailDomain.new(organization_id: create(:organization).id)).show?
    end

    it "permits an org admin for their org's domain" do
      user, org = org_admin
      assert policy(user, EmailDomain.new(organization_id: org.id)).show?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, EmailDomain.new).show?
    end
  end

  describe "#create? and #update?" do
    it "denies nil user" do
      refute policy(nil, EmailDomain.new).create?
      refute policy(nil, EmailDomain.new).update?
    end

    it "denies a regular user" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      refute policy(user.reload, EmailDomain.new(organization_id: org.id)).create?
      refute policy(user.reload, EmailDomain.new(organization_id: org.id)).update?
    end

    it "permits an org admin for their own org" do
      user, org = org_admin
      assert policy(user, EmailDomain.new(organization_id: org.id)).create?
      assert policy(user, EmailDomain.new(organization_id: org.id)).update?
    end

    it "denies an org admin for another org" do
      user, _org = org_admin
      refute policy(user, EmailDomain.new(organization_id: create(:organization).id)).create?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, EmailDomain.new).create?
      assert policy(create_system_admin, EmailDomain.new).update?
    end
  end

  describe "#index?" do
    it "denies nil user" do
      refute policy(nil, EmailDomain.new).index?
    end

    it "permits a regular user" do
      user = create(:another_user)
      create(:organization_member, organization: create(:organization), user: user)
      assert policy(user.reload, EmailDomain.new).index?
    end

    it "permits an org admin" do
      user, _org = org_admin
      assert policy(user, EmailDomain.new).index?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, EmailDomain.new).index?
    end
  end

  describe "#destroy?" do
    it "denies nil user" do
      refute policy(nil, EmailDomain.new).destroy?
    end

    it "denies a regular user" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      refute policy(user.reload, EmailDomain.new(organization_id: org.id)).destroy?
    end

    it "denies an org admin" do
      user, org = org_admin
      refute policy(user, EmailDomain.new(organization_id: org.id)).destroy?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, EmailDomain.new).destroy?
    end
  end

  describe "Scope" do
    let(:org) { create(:organization) }
    let(:other_org) { create(:organization) }
    let(:own_domain) { create(:email_domain, organization: org) }
    let(:other_domain) { create(:email_domain, organization: other_org) }
    before {
      own_domain
      other_domain
    }

    def resolve(user) = EmailDomainPolicy::Scope.new(user, EmailDomain.all).resolve

    it "returns empty for nil user" do
      assert_empty resolve(nil)
    end

    it "returns only the user's org domain" do
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      assert_equal [own_domain], resolve(user.reload).to_a
    end

    it "returns only the org admin's org domain" do
      user = create(:another_user)
      create(:organization_member, organization: org, user: user, role: :admin)
      assert_equal [own_domain], resolve(user.reload).to_a
    end

    it "returns all domains for a system admin" do
      result = resolve(create_system_admin)
      assert_includes result, own_domain
      assert_includes result, other_domain
    end
  end
end
