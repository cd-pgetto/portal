require "test_helper"

describe User do
  describe "validations" do
    it "is invalid without a first_name" do
      user = build(:another_user, first_name: nil)
      refute user.valid?
      assert user.errors[:first_name].present?
    end

    it "is invalid without a last_name" do
      user = build(:another_user, last_name: nil)
      refute user.valid?
      assert user.errors[:last_name].present?
    end

    it "is invalid without a password" do
      user = User.new(first_name: "Jane", last_name: "Doe", email_address: "jane@example.com")
      refute user.valid?
      assert user.errors[:password].present?
    end

    it "is invalid with a password shorter than 12 characters" do
      user = build(:another_user, password: "short")
      refute user.valid?
      assert user.errors[:password].present?
    end

    it "is invalid with a password longer than 72 characters" do
      user = build(:another_user, password: "a" * 73)
      refute user.valid?
      assert user.errors[:password].present?
    end

    it "is invalid without an email_address" do
      user = build(:another_user, email_address: nil)
      refute user.valid?
      assert user.errors[:email_address].present?
    end

    it "is invalid with a duplicate email_address (case-insensitive)" do
      create(:another_user, email_address: "dupe@example.com")
      user = build(:another_user, email_address: "DUPE@EXAMPLE.COM")
      refute user.valid?
      assert user.errors.of_kind?(:email_address, :taken)
    end

    describe "valid email addresses" do
      DomainNames::VALID_FULL_EMAIL_ADDRESSES.each do |address|
        it "accepts #{address}" do
          assert build(:another_user, email_address: address).valid?,
            "Expected #{address} to be a valid email address"
        end
      end
    end

    describe "invalid email addresses" do
      DomainNames::INVALID_FULL_EMAIL_ADDRESSES.each do |address|
        it "rejects #{address.inspect}" do
          user = build(:another_user, email_address: address)
          refute user.valid?, "Expected #{address.inspect} to be an invalid email address"
        end
      end
    end

    it "is not internal when belonging to a non-internal organization" do
      user = create(:another_user)
      create(:organization_member, organization: create(:organization), user: user)
      user.reload
      refute user.internal?
    end

    it "is internal when belonging to an internal organization" do
      user = create(:another_user)
      internal_org = create(:organization, internal: true)
      create(:organization_member, organization: internal_org, user: user)
      user.reload
      assert user.internal?
    end
  end

  describe "password" do
    it "responds to password, password=, and authenticate" do
      user = build(:another_user)
      assert_respond_to user, :password
      assert_respond_to user, :password=
      assert_respond_to user, :authenticate
      assert_respond_to User, :authenticate_by
    end

    it "has a password_digest column" do
      assert_includes User.column_names, "password_digest"
    end

    it "authenticates with the correct password" do
      user = create(:another_user, password: "secret-password-123")
      assert_equal user, user.authenticate("secret-password-123")
      assert_equal false, user.authenticate("wrong")
    end
  end

  describe "#full_name" do
    it "returns first and last name joined" do
      user = build(:another_user, first_name: "John", last_name: "Doe")
      assert_equal "John Doe", user.full_name
    end
  end

  describe "#practice_admin_or_owner?" do
    let(:organization) { create(:organization) }
    let(:practice) { create(:practice, organization: organization) }
    let(:other_practice) { create(:practice, organization: organization) }
    let(:user) do
      u = create(:another_user)
      create(:organization_member, organization: organization, user: u)
      create(:practice_member, practice: practice, user: u)
      u
    end

    it "returns true for an admin member" do
      PracticeMember.find_by(practice: practice, user: user).update!(role: :admin)
      assert user.practice_admin_or_owner?(practice_id: practice.id)
    end

    it "returns true for an owner member" do
      PracticeMember.find_by(practice: practice, user: user).update!(role: :owner)
      assert user.practice_admin_or_owner?(practice_id: practice.id)
    end

    it "returns false for a regular member" do
      refute user.practice_admin_or_owner?(practice_id: practice.id)
    end

    it "returns false for a practice the user is not a member of" do
      PracticeMember.find_by(practice: practice, user: user).update!(role: :admin)
      refute user.practice_admin_or_owner?(practice_id: other_practice.id)
    end

    it "returns false for an inactive admin" do
      PracticeMember.where(practice: practice, user: user).first.update!(role: :admin, active: false)
      refute user.practice_admin_or_owner?(practice_id: practice.id)
    end
  end
end
