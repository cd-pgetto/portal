require "rails_helper"

RSpec.describe "organizations/show", type: :view do
  let(:organization) { create(:big_dso, name: "Acme DSO") }

  context "when user is a system admin" do
    describe "renders attributes in <p>" do
      before { render Views::Admin::Organizations::Show.new(organization:) }

      it { expect(rendered).to have_text("Acme DSO") }
      it { expect(rendered).to have_text("Subdomain: #{organization.subdomain}") }
      it { expect(rendered).to have_text("Allow Password Auth: #{organization.allows_password_auth ? "Yes" : "No"}") }

      it { expect(rendered).to have_css("a[href='#{admin_organizations_path}']") }
      it { expect(rendered).to have_css("a[href='#{edit_admin_organization_path(organization)}']") }
      it { expect(rendered).to have_css("form[action='#{admin_organization_path(organization)}'][method='post']") }

      # it { expect(rendered).to have_text("Email Domains") }
      # it { expect(rendered).to have_css("button[data-action='click->inline-form#toggleForm']") }
      # it { expect(rendered).to have_text(organization.email_domains.first.domain_name) }
      # it { expect(rendered).to have_text(organization.email_domains.second.domain_name) }
      # it { expect(rendered).to have_css("form[action='#{admin_organization_email_domain_path(organization, organization.email_domains.first)}'][method='post']") }
      # it { expect(rendered).to have_css("form[action='#{admin_organization_email_domain_path(organization, organization.email_domains.second)}'][method='post']") }

      it { expect(rendered).to have_text("Identity Providers") }
      skip { expect(rendered).to have_css("a[href='#{new_admin_organization_identity_provider_path(organization)}']") }
      skip { expect(rendered).to have_text(organization.identity_providers.first.name) }
      skip { expect(rendered).to have_css("form[action='#{admin_organization_identity_provider_path(organization, organization.identity_providers.first)}'][method='post']") }
    end
  end
end
