require "test_helper"

describe PracticeMemberPolicy do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:target_user) { create_member_in(practice) }
  let(:record) { PracticeMember.find_by!(practice: practice, user: target_user) }

  def policy(user) = PracticeMemberPolicy.new(user, record)

  describe "#create?, #update?, #destroy?" do
    it "denies nil user" do
      refute policy(nil).create?
      refute policy(nil).update?
      refute policy(nil).destroy?
    end

    it "denies a regular practice member" do
      user = create_member_in(practice)
      refute policy(user).create?
      refute policy(user).update?
      refute policy(user).destroy?
    end

    it "permits a practice admin" do
      user = create_member_in(practice, role: :admin)
      assert policy(user).create?
      assert policy(user).update?
      assert policy(user).destroy?
    end

    it "permits a practice owner" do
      user = create_member_in(practice, role: :owner)
      assert policy(user).create?
      assert policy(user).update?
      assert policy(user).destroy?
    end

    it "denies admin of a different practice" do
      other_practice = create(:practice, organization: organization)
      user = create_member_in(other_practice, role: :admin)
      refute policy(user).create?
      refute policy(user).update?
      refute policy(user).destroy?
    end
  end
end
