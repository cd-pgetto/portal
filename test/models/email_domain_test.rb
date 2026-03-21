require "test_helper"

describe EmailDomain do
  let(:org) { create(:organization) }

  it "is invalid without a domain_name" do
    domain = build(:email_domain, organization: org, domain_name: nil)
    refute domain.valid?
    assert domain.errors[:domain_name].present?
  end

  it "is invalid with a duplicate domain_name" do
    create(:email_domain, domain_name: "example.com", organization: org)
    duplicate = build(:email_domain, domain_name: "example.com", organization: create(:organization))
    refute duplicate.valid?
    assert duplicate.errors[:domain_name].present?
  end

  it "is case-insensitive for uniqueness" do
    create(:email_domain, domain_name: "example.com", organization: org)
    duplicate = build(:email_domain, domain_name: "EXAMPLE.COM", organization: create(:organization))
    refute duplicate.valid?
  end

  describe "valid domain name formats" do
    DomainNames::VALID_FULL_DOMAIN_NAMES.each do |name|
      it "accepts #{name}" do
        assert build(:email_domain, domain_name: name, organization: create(:organization)).valid?
      end
    end
  end

  describe "invalid domain name formats" do
    DomainNames::INVALID_FULL_DOMAIN_NAMES.each do |name|
      it "rejects #{name.inspect}" do
        domain = build(:email_domain, domain_name: name, organization: create(:organization))
        refute domain.valid?, "Expected #{name.inspect} to be invalid"
      end
    end
  end
end
