require "test_helper"

describe UserPolicy do
  def policy(user, record) = UserPolicy.new(user, record)

  describe "#create?" do
    it "permits nil user (sign up)" do
      assert policy(nil, User.new).create?
    end

    it "denies a regular user" do
      refute policy(create(:another_user), User.new).create?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, User.new).create?
    end
  end

  describe "#show?, #edit?, #update?" do
    it "denies nil user" do
      refute policy(nil, User.new).show?
      refute policy(nil, User.new).edit?
      refute policy(nil, User.new).update?
    end

    it "permits own record" do
      user = create(:another_user)
      assert policy(user, user).show?
      assert policy(user, user).edit?
      assert policy(user, user).update?
    end

    it "denies another user's record" do
      user = create(:another_user)
      other = create(:another_user)
      refute policy(user, other).show?
      refute policy(user, other).edit?
      refute policy(user, other).update?
    end

    it "permits a system admin" do
      admin = create_system_admin
      assert policy(admin, User.new).show?
      assert policy(admin, User.new).edit?
      assert policy(admin, User.new).update?
    end
  end

  describe "#destroy?" do
    it "denies nil user" do
      refute policy(nil, User.new).destroy?
    end

    it "denies own record" do
      user = create(:another_user)
      refute policy(user, user).destroy?
    end

    it "denies another user's record" do
      refute policy(create(:another_user), create(:another_user)).destroy?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, User.new).destroy?
    end
  end

  describe "#index?" do
    it "denies nil user" do
      refute policy(nil, User.new).index?
    end

    it "denies a regular user" do
      refute policy(create(:another_user), User.new).index?
    end

    it "permits a system admin" do
      assert policy(create_system_admin, User.new).index?
    end
  end

  describe "Scope" do
    let(:user_a) { create(:another_user) }
    let(:user_b) { create(:another_user) }
    before {
      user_a
      user_b
    }

    def resolve(user) = UserPolicy::Scope.new(user, User.all).resolve

    it "returns empty for nil user" do
      assert_empty resolve(nil)
    end

    it "returns empty for a regular user" do
      assert_empty resolve(create(:another_user))
    end

    it "returns all users for a system admin" do
      result = resolve(create_system_admin)
      assert_includes result, user_a
      assert_includes result, user_b
    end
  end
end
