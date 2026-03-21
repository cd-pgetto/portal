require "test_helper"

describe IdentityProviderPolicy do
  def policy(user, record) = IdentityProviderPolicy.new(user, record)

  def org_admin
    user = create(:another_user)
    org = create(:organization)
    create(:organization_member, organization: org, user: user, role: :admin)
    [user.reload, org]
  end

  describe "#index?" do
    it "denies nil user" do
      refute policy(nil, IdentityProvider::Shared.new).index?
    end

    it "denies a regular user" do
      user = create(:another_user)
      create(:organization_member, organization: create(:organization), user: user)
      refute policy(user.reload, IdentityProvider::Shared.new).index?
    end

    it "denies an org admin (for shared providers)" do
      user, _org = org_admin
      refute policy(user, IdentityProvider::Shared.new).index?
    end

    it "denies an org admin for a dedicated provider in their org" do
      user, org = org_admin
      record = create(:okta_identity_provider, organization: org)
      refute policy(user, record).index?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, IdentityProvider::Shared.new).index?
    end
  end

  describe "#show?, #create?, #update?" do
    it "denies nil user" do
      refute policy(nil, IdentityProvider::Shared.new).show?
    end

    it "denies a regular user" do
      user = create(:another_user)
      create(:organization_member, organization: create(:organization), user: user)
      refute policy(user.reload, IdentityProvider::Shared.new).show?
    end

    it "permits an org admin for their own dedicated provider" do
      user, org = org_admin
      record = create(:okta_identity_provider, organization: org)
      assert policy(user, record).show?
      assert policy(user, record).create?
      assert policy(user, record).update?
    end

    it "denies an org admin for a shared provider" do
      user, _org = org_admin
      refute policy(user, IdentityProvider::Shared.new).show?
    end

    it "denies an org admin for a dedicated provider in another org" do
      user, _org = org_admin
      record = create(:okta_identity_provider, organization: create(:organization))
      refute policy(user, record).show?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, IdentityProvider::Shared.new).show?
      assert policy(create_system_admin, IdentityProvider::Shared.new).create?
    end
  end

  describe "#destroy?" do
    it "denies nil user" do
      refute policy(nil, IdentityProvider::Shared.new).destroy?
    end

    it "denies a regular user" do
      user = create(:another_user)
      create(:organization_member, organization: create(:organization), user: user)
      refute policy(user.reload, IdentityProvider::Shared.new).destroy?
    end

    it "denies an org admin even for their own dedicated provider" do
      user, org = org_admin
      record = create(:okta_identity_provider, organization: org)
      refute policy(user, record).destroy?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, IdentityProvider::Shared.new).destroy?
    end
  end

  describe "Scope" do
    let(:provider_a) { create(:identity_provider) }
    let(:provider_b) { create(:google_identity_provider) }
    before {
      provider_a
      provider_b
    }

    def resolve(user) = IdentityProviderPolicy::Scope.new(user, IdentityProvider.all).resolve

    it "returns empty for nil user" do
      assert_empty resolve(nil)
    end

    it "returns empty for a regular user" do
      user = create(:another_user)
      create(:organization_member, organization: create(:organization), user: user)
      assert_empty resolve(user.reload)
    end

    it "returns empty for an org admin (even with dedicated provider)" do
      user = create(:another_user)
      org = create(:organization)
      create(:organization_member, organization: org, user: user, role: :admin)
      create(:okta_identity_provider, organization: org)
      assert_empty resolve(user.reload)
    end

    it "returns all providers for a system admin" do
      result = resolve(create_system_admin)
      assert_includes result, provider_a
      assert_includes result, provider_b
    end
  end
end
