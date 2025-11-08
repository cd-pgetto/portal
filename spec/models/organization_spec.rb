# == Schema Information
#
# Table name: organizations
#
#  id                   :bigint           not null, primary key
#  allows_password_auth :boolean          default(TRUE), not null
#  name                 :string           not null
#  subdomain            :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_organizations_on_subdomain  (subdomain) UNIQUE
#
require "rails_helper"

RSpec.describe Organization, type: :model do
  subject { build(:organization) }

  describe "associations" do
    it { is_expected.to have_many(:credentials).dependent(:destroy) }
    it { is_expected.to have_many(:identity_providers).through(:credentials) }
    it "is expected to have many shared identity providers through credentials" do
      subject.save!
      identity_provider = create(:identity_provider, availability: "shared")
      subject.identity_providers << identity_provider

      expect(subject.shared_identity_providers.length).to eq(1)
      expect(subject.shared_identity_providers.first).to eq(identity_provider)
    end
    it "is expected to have many dedicated identity providers through credentials" do
      subject.save!
      identity_provider = create(:identity_provider, availability: "dedicated")
      subject.identity_providers << identity_provider

      expect(subject.dedicated_identity_providers.length).to eq(1)
      expect(subject.dedicated_identity_providers.first).to eq(identity_provider)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:subdomain) }
    it { is_expected.to validate_uniqueness_of(:subdomain).ignoring_case_sensitivity }
    it { is_expected.to validate_length_of(:subdomain).is_at_least(1).is_at_most(63) }

    context "with valid subdomain names" do
      DomainNames::VALID_SUBDOMAIN_NAMES.each do |domain_name|
        it { is_expected.to allow_value(domain_name).for(:subdomain) }
      end
    end

    context "with invalid subdomain names" do
      DomainNames::INVALID_SUBDOMAIN_NAMES.each do |domain_name|
        it { is_expected.not_to allow_value(domain_name).for(:subdomain) }
      end
    end

    it { is_expected.to normalize(:subdomain).from(" ExAmPlE ").to("example") }
  end
end
