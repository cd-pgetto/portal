require "test_helper"

describe PracticePolicy do
  def policy(user, record) = PracticePolicy.new(user, record)

  describe "#show?" do
    it "denies nil user" do
      refute policy(nil, Practice.new).show?
    end

    it "permits a regular practice member" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      practice = create(:practice, organization: org)
      create(:practice_member, practice: practice, user: user)
      assert policy(user.reload, practice).show?
    end

    it "denies a user without practice membership" do
      user = create(:another_user)
      create(:organization_member, organization: create(:organization), user: user)
      refute policy(user.reload, Practice.new(organization_id: create(:organization).id)).show?
    end

    it "permits a practice admin" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      practice = create(:practice, organization: org)
      create(:practice_member, practice: practice, user: user, role: :admin)
      assert policy(user.reload, practice).show?
    end

    it "denies a user with only an inactive membership" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      practice = create(:practice, organization: org)
      create(:practice_member, practice: practice, user: user, active: false)
      refute policy(user.reload, practice).show?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, Practice.new).show?
    end
  end

  describe "#create?" do
    it "denies nil user" do
      refute policy(nil, Practice.new).create?
    end

    it "denies a regular practice member" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      practice = create(:practice, organization: org)
      create(:practice_member, practice: practice, user: user)
      refute policy(user.reload, practice).create?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, Practice.new).create?
    end
  end

  describe "#edit? and #update?" do
    it "denies nil user" do
      refute policy(nil, Practice.new).edit?
      refute policy(nil, Practice.new).update?
    end

    it "denies a regular practice member" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      practice = create(:practice, organization: org)
      create(:practice_member, practice: practice, user: user)
      refute policy(user.reload, practice).edit?
      refute policy(user.reload, practice).update?
    end

    it "permits a practice admin" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      practice = create(:practice, organization: org)
      create(:practice_member, practice: practice, user: user, role: :admin)
      assert policy(user.reload, practice).edit?
      assert policy(user.reload, practice).update?
    end

    it "denies a user with only an inactive admin membership" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      practice = create(:practice, organization: org)
      create(:practice_member, practice: practice, user: user, role: :admin, active: false)
      refute policy(user.reload, practice).edit?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, Practice.new).edit?
      assert policy(create_system_admin, Practice.new).update?
    end
  end

  describe "#destroy?" do
    it "denies nil user" do
      refute policy(nil, Practice.new).destroy?
    end

    it "denies a practice admin" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      practice = create(:practice, organization: org)
      create(:practice_member, practice: practice, user: user, role: :admin)
      refute policy(user.reload, practice).destroy?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, Practice.new).destroy?
    end
  end

  describe "#select?" do
    it "denies nil user" do
      refute policy(nil, Practice.new).select?
    end

    it "permits a regular practice member" do
      org = create(:organization)
      user = create(:another_user)
      create(:organization_member, organization: org, user: user)
      practice = create(:practice, organization: org)
      create(:practice_member, practice: practice, user: user)
      assert policy(user.reload, practice).select?
    end

    it "denies a user without practice membership" do
      user = create(:another_user)
      create(:organization_member, organization: create(:organization), user: user)
      refute policy(user.reload, Practice.new(organization_id: create(:organization).id)).select?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, Practice.new).select?
    end
  end

  describe "Scope" do
    let(:practice) { create(:practice_with_org) }
    let(:other_practice) { create(:practice_with_org) }
    before {
      practice
      other_practice
    }

    def resolve(user) = PracticePolicy::Scope.new(user, Practice.all).resolve

    it "returns empty for nil user" do
      assert_empty resolve(nil)
    end

    it "returns only the user's practice" do
      user = create(:another_user)
      create(:organization_member, organization: practice.organization, user: user)
      create(:practice_member, practice: practice, user: user)
      assert_equal [practice], resolve(user.reload).to_a
    end

    it "returns empty for a non-member" do
      assert_empty resolve(create(:another_user))
    end

    it "excludes practices with only inactive memberships" do
      user = create(:another_user)
      create(:organization_member, organization: practice.organization, user: user)
      create(:practice_member, practice: practice, user: user, active: false)
      refute_includes resolve(user.reload), practice
    end

    it "returns all practices for a system admin" do
      result = resolve(create_system_admin)
      assert_includes result, practice
      assert_includes result, other_practice
    end
  end
end
