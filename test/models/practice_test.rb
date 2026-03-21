require "test_helper"

describe Practice do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }

  it "is invalid without a name" do
    p = build(:practice, name: nil, organization: organization)
    refute p.valid?
    assert p.errors[:name].present?
  end

  describe "#first_owner" do
    it "returns nil when there are no members" do
      assert_nil practice.first_owner
    end

    it "returns nil when there is no owner" do
      user = create(:another_user)
      create(:organization_member, organization: organization, user: user)
      create(:practice_member, practice: practice, user: user, role: :member)
      assert_nil practice.first_owner
    end

    it "returns the first active owner" do
      owner = create(:another_user)
      create(:organization_member, organization: organization, user: owner)
      create(:practice_member, practice: practice, user: owner, role: :owner)
      assert_equal owner, practice.first_owner
    end

    it "returns nil when the owner is inactive" do
      owner = create(:another_user)
      create(:organization_member, organization: organization, user: owner)
      create(:practice_member, practice: practice, user: owner, role: :owner, active: false)
      assert_nil practice.first_owner
    end
  end
end
