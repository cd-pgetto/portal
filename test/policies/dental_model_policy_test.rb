require "test_helper"

describe DentalModelPolicy do
  let(:practice) { create(:practice_with_org) }
  let(:patient) { create(:patient, practice: practice) }
  let(:dental_model) { create(:dental_model, patient: patient) }

  def policy(user) = DentalModelPolicy.new(user, dental_model)

  describe "#index?, #show?, #create?, #update?" do
    it "denies nil user" do
      refute policy(nil).index?
      refute policy(nil).show?
      refute policy(nil).create?
      refute policy(nil).update?
    end

    it "permits a practice member" do
      user = create(:another_user)
      create(:practice_member, practice: practice, user: user)
      assert policy(user).index?
      assert policy(user).show?
      assert policy(user).create?
      assert policy(user).update?
    end

    it "denies a non-member" do
      refute policy(create(:another_user)).index?
    end

    it "permits a system admin" do
      assert policy(create_system_admin).index?
      assert policy(create_system_admin).show?
    end
  end

  describe "#destroy?" do
    it "denies nil user" do
      refute policy(nil).destroy?
    end

    it "denies a regular practice member" do
      user = create(:another_user)
      create(:practice_member, practice: practice, user: user)
      refute policy(user).destroy?
    end

    it "permits a system admin" do
      assert policy(create_system_admin).destroy?
    end
  end
end
