require "test_helper"

describe PatientPolicy do
  let(:practice) { create(:practice_with_org) }
  let(:patient) { create(:patient, practice: practice) }

  def policy(user) = PatientPolicy.new(user, patient)

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

  describe "Scope" do
    let(:other_practice) { create(:practice_with_org) }
    let(:own_patient) { create(:patient, practice: practice) }
    let(:other_patient) { create(:patient, practice: other_practice) }
    before {
      own_patient
      other_patient
    }

    def resolve(user) = PatientPolicy::Scope.new(user, Patient.all).resolve

    it "returns empty for nil user" do
      assert_empty resolve(nil)
    end

    it "returns only patients from the user's practice" do
      user = create(:another_user)
      create(:practice_member, practice: practice, user: user)
      assert_equal [own_patient], resolve(user).to_a
    end

    it "returns empty for a non-member" do
      assert_empty resolve(create(:another_user))
    end

    it "returns all patients for a system admin" do
      result = resolve(create_system_admin)
      assert_includes result, own_patient
      assert_includes result, other_patient
    end
  end
end
