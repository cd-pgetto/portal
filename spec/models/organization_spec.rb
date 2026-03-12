# == Schema Information
#
# Table name: organizations
# Database name: primary
#
#  id                    :uuid             not null, primary key
#  email_domains_count   :integer          default(0), not null
#  name                  :string           not null
#  password_auth_allowed :boolean          default(TRUE), not null
#  practices_count       :integer          default(0), not null
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
    it { is_expected.to have_many(:organization_shared_identity_providers).dependent(:destroy) }
    it { is_expected.to have_many(:shared_identity_providers).through(:organization_shared_identity_providers) }
    it { is_expected.to have_one(:dedicated_identity_provider) }
    it { is_expected.to accept_nested_attributes_for(:organization_shared_identity_providers).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:dedicated_identity_provider).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:email_domains).allow_destroy(true) }

    it "returns shared identity providers through the join table" do
      subject.save!
      idp = create(:identity_provider)
      subject.shared_identity_providers << idp
      expect(subject.shared_identity_providers).to contain_exactly(idp)
    end

    it "returns the dedicated identity provider via has_one" do
      subject.save!
      okta = create(:okta_identity_provider, organization: subject)
      expect(subject.reload.dedicated_identity_provider).to eq(okta)
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

      context "with at least one shared identity provider" do
        before { subject.shared_identity_providers << create(:google_identity_provider) }

        it { is_expected.to be_valid }
      end

      context "with a dedicated identity provider" do
        let(:org) { create(:organization, password_auth_allowed: true) }

        before do
          org.password_auth_allowed = false
          org.build_dedicated_identity_provider(
            name: "Test IdP", strategy: "test-dedicated", icon_url: "test.svg",
            client_id: "client-id", client_secret: "secret"
          )
        end

        it "is valid" do
          expect(org).to be_valid
        end
      end
    end

    context "authentication mode exclusivity" do
      let!(:org) { create(:organization) }

      it "is invalid with both shared and dedicated identity providers" do
        org.shared_identity_providers << create(:identity_provider)
        org.build_dedicated_identity_provider(
          name: "Test IdP", strategy: "test-dedicated", icon_url: "test.svg",
          client_id: "client-id", client_secret: "secret"
        )
        expect(org).not_to be_valid
        expect(org.errors[:base]).to include(match(/cannot have both/))
      end

      it "is invalid when password auth is allowed with a dedicated identity provider" do
        org.build_dedicated_identity_provider(
          name: "Test IdP", strategy: "test-dedicated", icon_url: "test.svg",
          client_id: "client-id", client_secret: "secret"
        )
        expect(org).not_to be_valid
        expect(org.errors[:base]).to include(match(/password authentication must be disabled/))
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

      it "returns an Organization::Null if no matching email domain exists" do
        result = Organization.find_by_email("user@nonexistentdomain.com")
        expect(result).to be_an_instance_of(Organization::Null)
      end
    end

    describe "#identity_providers" do
      let!(:org) { create(:organization) }

      it "includes shared identity providers" do
        idp = create(:identity_provider)
        org.shared_identity_providers << idp
        expect(org.identity_providers).to include(idp)
      end

      it "includes the dedicated identity provider" do
        okta = create(:okta_identity_provider, organization: org)
        expect(org.identity_providers).to include(okta)
      end
    end

    describe "#identity_providers_by_email" do
      it "returns the identity providers for an organization based on email" do
        provider1 = create(:identity_provider, strategy: "strategy1", client_id: "client_id_1")
        provider2 = create(:identity_provider, strategy: "strategy2", client_id: "client_id_2")
        org = create(:organization)
        org.email_domains.create!(domain_name: "example.com")
        org.organization_shared_identity_providers.create!(identity_provider: provider1)
        org.organization_shared_identity_providers.create!(identity_provider: provider2)

        result = Organization.identity_providers_by_email("user@example.com")
        expect(result).to match_array([provider1, provider2])
      end
    end

    describe "#shared_identity_provider_ids and #shared_identity_provider_ids=" do
      let!(:organization) { create(:organization) }
      let!(:shared_provider1) { create(:identity_provider) }
      let!(:shared_provider2) { create(:identity_provider) }

      before { organization.shared_identity_providers << shared_provider1 }

      it "returns the IDs of associated shared identity providers" do
        expect(organization.shared_identity_provider_ids).to contain_exactly(shared_provider1.id)
      end

      it "adds and removes shared identity providers correctly" do
        organization.shared_identity_provider_ids = [shared_provider2.id]
        organization.save!

        expect(organization.reload.shared_identity_providers).to contain_exactly(shared_provider2)
      end
    end
  end
end
