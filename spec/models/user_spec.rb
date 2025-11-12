# == Schema Information
#
# Table name: users
#
#  id                  :uuid             not null, primary key
#  email_address       :string           not null
#  first_name          :string           not null
#  last_name           :string           not null
#  original_first_name :string           not null
#  original_last_name  :string           not null
#  password_digest     :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    xit { is_expected.to have_many(:identities).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }

    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(12).is_at_most(72) }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
    context "with valid email addresses" do
      DomainNames::VALID_FULL_EMAIL_ADDRESSES.each do |address|
        it { should allow_value(address).for(:email_address) }
      end
    end

    context "with invalid email addresses" do
      DomainNames::INVALID_FULL_EMAIL_ADDRESSES.each do |email|
        it { should_not allow_value(email).for(:email_address) }
      end
    end

    context "with duplicate email addresses" do
      before { create(:user) }

      it { is_expected.to be_invalid }
      it { is_expected.to have_validation_error_of_kind(:email_address, :taken) }
    end

    # context "internal users" do
    #   subject { create(:internal_user) }

    #   let!(:perceptive_org) { Organization::Perceptive.instance.organization }

    #   it { is_expected.to be_valid }
    #   it { is_expected.to be_internal }
    # end
  end

  describe "encrypted attributes" do
    it { is_expected.to encrypt(:first_name).deterministic(true).ignore_case(true) }
    it { is_expected.to encrypt(:last_name).deterministic(true).ignore_case(true) }
    it { is_expected.to encrypt(:email_address).deterministic(true).downcase(true) }
  end

  describe "password" do
    it "includes has_secure_password" do
      expect(subject).to respond_to(:password)
      expect(subject).to respond_to(:password=)
      expect(subject).to respond_to(:authenticate)
      expect(User).to respond_to(:authenticate_by)
    end

    it "requires a password_digest column" do
      expect(User.column_names).to include("password_digest")
    end

    it "authenticates with correct password" do
      user = create(:user, password: "secret-password-123")
      expect(user.authenticate("secret-password-123")).to eq(user)
      expect(user.authenticate("wrong")).to be_falsey
    end
  end

  describe "methods" do
    describe "#full_name" do
      subject { build(:user, first_name: "John", last_name: "Doe") }
      it "returns the full name" do
        expect(subject.full_name).to eq("John Doe")
      end
    end
  end
end
