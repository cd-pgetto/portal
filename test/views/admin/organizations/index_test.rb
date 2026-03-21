require "test_helper"

class AdminOrganizationsIndexTest < ActionView::TestCase
  it "renders the organizations list" do
    organization = create(:organization, name: "Acme Corp")
    render Views::Admin::Organizations::Index.new(organizations: [organization])
    assert_includes rendered, "Organizations"
    assert_select "a[href='#{new_admin_organization_path}']"
    assert_includes rendered, "Acme Corp"
    assert_select "a[href='#{admin_organization_path(organization)}']"
    assert_select "form[action='#{admin_organization_path(organization)}'][method='post']"
  end
end
