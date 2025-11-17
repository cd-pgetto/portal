# == Schema Information
#
# Table name: organizations
# Database name: primary
#
#  id                    :uuid             not null, primary key
#  name                  :string           not null
#  password_auth_allowed :boolean          default(TRUE), not null
#  subdomain             :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_organizations_on_subdomain  (subdomain) UNIQUE
#
require "rails_helper"

RSpec.describe Organization, type: :model do
  subject { build(:organization) }

  describe "associations" do
    it { is_expected.to have_many(:email_domains).dependent(:destroy) }
    it { is_expected.to have_many(:credentials).dependent(:destroy) }
    it { is_expected.to have_many(:identity_providers).through(:credentials) }
    it { is_expected.to accept_nested_attributes_for(:credentials).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:email_domains).allow_destroy(true) }
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

    context "when not allowing password auth" do
      before { subject.password_auth_allowed = false }

      context "without any identity providers" do
        it { is_expected.not_to be_valid }
      end
      context "with at least one identity provider" do
        before { subject.identity_providers << create(:google_identity_provider) }

        it { is_expected.to be_valid }
      end
    end
  end

  describe "methods" do
    describe "#find_by_email" do
      let!(:organization) { create(:organization) }
      let!(:email_domain) { create(:email_domain, organization:) }

      it "returns the organization for a matching email domain" do
        result = Organization.find_by_email("user@#{email_domain.domain_name}")
        expect(result).to eq(organization)
      end

      it "is case insensitive for the email domain" do
        result = Organization.find_by_email("user@#{email_domain.domain_name.upcase}")
        expect(result).to eq(organization)
      end

      it "returns nil if no matching email domain exists" do
        result = Organization.find_by_email("user@nonexistentdomain.com")
        expect(result).to be_an_instance_of(Organization::Null)
      end
    end

    describe "#identity_providers_by_email" do
      it "returns the identity providers for organization based on an email address" do
        provider1 = create(:identity_provider, strategy: "strategy1", client_id: "client_id_1")
        provider2 = create(:identity_provider, strategy: "strategy2", client_id: "client_id_2")
        org = create(:organization)
        org.email_domains.create!(domain_name: "example.com")
        org.credentials.create(identity_provider: provider1)
        org.credentials.create(identity_provider: provider2)

        result = Organization.identity_providers_by_email("user@example.com")
        expect(result).to match_array([provider1, provider2])
      end
    end

    describe ".shared_identity_provider_ids and .shared_identity_provider_ids=" do
      let!(:organization) { create(:organization) }
      let!(:shared_provider1) { create(:identity_provider, availability: "shared") }
      let!(:shared_provider2) { create(:identity_provider, availability: "shared") }
      let!(:dedicated_provider) { create(:identity_provider, availability: "dedicated") }

      before do
        organization.identity_providers << shared_provider1
        organization.identity_providers << dedicated_provider
      end

      it "returns the IDs of associated shared identity providers" do
        expect(organization.shared_identity_provider_ids).to contain_exactly(shared_provider1.id)
      end

      it "adds and removes shared identity providers correctly" do
        # Add shared_provider2 and remove shared_provider1
        organization.shared_identity_provider_ids = [shared_provider2.id]
        organization.save!

        expect(organization.shared_identity_providers).to contain_exactly(shared_provider2)
        expect(organization.identity_providers).to include(dedicated_provider)
      end
    end
  end
end
