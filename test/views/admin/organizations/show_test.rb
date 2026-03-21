require "test_helper"

class AdminOrganizationsShowTest < ActionView::TestCase
  let(:organization) { create(:big_dso, name: "Acme DSO") }

  before { render Views::Admin::Organizations::Show.new(organization: organization) }

  it "renders the organization name" do
    assert_includes rendered, "Acme DSO"
  end

  it "renders subdomain" do
    assert_includes rendered, "Subdomain:"
    assert_includes rendered, organization.subdomain
  end

  it "renders back and edit links" do
    assert_select "a[href='#{admin_organizations_path}']"
    assert_select "a[href='#{edit_admin_organization_path(organization)}']"
    assert_select "form[action='#{admin_organization_path(organization)}'][method='post']"
  end

  it "renders email domains section" do
    assert_includes rendered, "Email Domains"
    assert_includes rendered, organization.email_domains.first.domain_name
  end

  it "renders identity provider sections" do
    assert_includes rendered, "Shared Identity Providers"
    assert_includes rendered, "Dedicated Identity Providers"
  end

  it "renders all identity provider names" do
    organization.identity_providers.each do |idp|
      assert_includes rendered, idp.name
    end
  end
end
