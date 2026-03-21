require "test_helper"

describe Organization do
  describe "validations" do
    it "is invalid without a name" do
      org = build(:organization, name: nil)
      refute org.valid?
      assert org.errors[:name].present?
    end

    it "is invalid without a subdomain" do
      org = build(:organization, subdomain: nil)
      refute org.valid?
      assert org.errors[:subdomain].present?
    end

    it "is invalid with a duplicate subdomain (case-insensitive)" do
      create(:organization, subdomain: "acme-dupe")
      org = build(:organization, subdomain: "ACME-DUPE")
      refute org.valid?
      assert org.errors[:subdomain].present?
    end

    it "normalizes subdomain to lowercase and strips whitespace" do
      org = create(:organization, subdomain: " ExAmPlE-norm ")
      assert_equal "example-norm", org.subdomain
    end

    describe "valid subdomain formats" do
      DomainNames::VALID_SUBDOMAIN_NAMES.each do |name|
        it "accepts #{name}" do
          assert build(:organization, subdomain: name).valid?,
            "Expected #{name.inspect} to be a valid subdomain"
        end
      end
    end

    describe "invalid subdomain formats" do
      DomainNames::INVALID_SUBDOMAIN_NAMES.each do |name|
        it "rejects #{name.inspect}" do
          org = build(:organization, subdomain: name)
          refute org.valid?, "Expected #{name.inspect} to be an invalid subdomain"
        end
      end
    end

    describe "when password auth is disabled" do
      it "is invalid without any identity providers" do
        org = build(:organization, password_auth_allowed: false)
        refute org.valid?
      end

      it "is valid with a shared identity provider" do
        org = create(:organization, password_auth_allowed: true)
        org.shared_identity_providers << create(:identity_provider)
        org.password_auth_allowed = false
        assert org.valid?
      end

      it "is valid with a dedicated identity provider" do
        org = create(:organization, password_auth_allowed: true)
        org.build_dedicated_identity_provider(
          name: "Test IdP", strategy: "test-dedicated", icon_url: "test.svg",
          client_id: "client-id", client_secret: "secret"
        )
        org.password_auth_allowed = false
        assert org.valid?
      end
    end

    describe "authentication mode exclusivity" do
      it "is invalid with both shared and dedicated identity providers" do
        org = create(:organization)
        org.shared_identity_providers << create(:identity_provider)
        org.build_dedicated_identity_provider(
          name: "Test IdP", strategy: "test-dedicated", icon_url: "test.svg",
          client_id: "client-id", client_secret: "secret"
        )
        refute org.valid?
        assert org.errors[:base].any? { |e| e.match?(/cannot have both/) }
      end

      it "is invalid when password auth is allowed with a dedicated identity provider" do
        org = create(:organization)
        org.build_dedicated_identity_provider(
          name: "Test IdP", strategy: "test-dedicated", icon_url: "test.svg",
          client_id: "client-id", client_secret: "secret"
        )
        refute org.valid?
        assert org.errors[:base].any? { |e| e.match?(/password authentication must be disabled/) }
      end
    end
  end

  describe ".find_by_email" do
    let(:org) { create(:organization) }
    let(:email_domain) { create(:email_domain, organization: org) }

    it "returns the organization for a matching email domain" do
      assert_equal org, Organization.find_by_email("user@#{email_domain.domain_name}")
    end

    it "is case insensitive for the email domain" do
      assert_equal org, Organization.find_by_email("user@#{email_domain.domain_name.upcase}")
    end

    it "returns an Organization::Null when no match exists" do
      assert_kind_of Organization::Null, Organization.find_by_email("user@nonexistentdomain.com")
    end
  end

  describe "#identity_providers" do
    let(:org) { create(:organization) }

    it "includes shared identity providers" do
      idp = create(:identity_provider)
      org.shared_identity_providers << idp
      assert_includes org.identity_providers, idp
    end

    it "includes the dedicated identity provider" do
      okta = create(:okta_identity_provider, organization: org)
      assert_includes org.identity_providers, okta
    end
  end

  describe ".identity_providers_by_email" do
    it "returns identity providers for an organization matched by email domain" do
      provider1 = create(:identity_provider, strategy: "strategy1", client_id: "client_id_1")
      provider2 = create(:identity_provider, strategy: "strategy2", client_id: "client_id_2")
      org = create(:organization)
      org.email_domains.create!(domain_name: "identbyemail.com")
      org.organization_shared_identity_providers.create!(identity_provider: provider1)
      org.organization_shared_identity_providers.create!(identity_provider: provider2)

      result = Organization.identity_providers_by_email("user@identbyemail.com")
      assert_equal [provider1, provider2].to_set, result.to_set
    end
  end

  describe "#shared_identity_provider_ids=" do
    let(:org) { create(:organization) }
    let(:provider1) { create(:identity_provider) }
    let(:provider2) { create(:identity_provider) }

    before { org.shared_identity_providers << provider1 }

    it "returns the IDs of associated shared identity providers" do
      assert_equal [provider1.id], org.shared_identity_provider_ids
    end

    it "adds and removes shared identity providers" do
      org.shared_identity_provider_ids = [provider2.id]
      org.save!
      assert_equal [provider2], org.reload.shared_identity_providers.to_a
    end
  end
end
