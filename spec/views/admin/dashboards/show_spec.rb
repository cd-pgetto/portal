require "rails_helper"

RSpec.describe "dashboards/show", type: :view do
  let(:organization) { create(:org_with_domains_and_oauth_providers, name: "Acme Corp") }
  let(:user) { create(:user, organization:) }

  it "renders the dashboard view" do
    render Views::Admin::Dashboards::Show.new

    expect(rendered).to have_text("Organizations#{Organization.count}")
    expect(rendered).to have_css("a[href='#{admin_organizations_path}']")
    expect(rendered).to have_text("Users#{User.count}")
  end
end
