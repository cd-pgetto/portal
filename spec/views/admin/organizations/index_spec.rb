require "rails_helper"

RSpec.describe "admin/organizations/index", type: :view do
  let(:organization) { create(:organization, name: "Acme Corp") }
  let(:organizations) { [organization] }

  it "renders the organizations list" do
    render Views::Admin::Organizations::Index.new(organizations:)

    expect(rendered).to have_text("Organizations")
    expect(rendered).to have_css("a[href='#{new_admin_organization_path}']", text: "New")

    expect(rendered).to have_text("Acme Corp")
    expect(rendered).to have_css("a[href='#{admin_organization_path(organization)}']")
    expect(rendered).to have_css("form[action='#{admin_organization_path(organization)}'][method='post']")
  end
end
