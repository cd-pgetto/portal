require "test_helper"

class AdminOrganizationsEditTest < ActionView::TestCase
  it "renders the edit organization form" do
    organization = create(:big_dso)
    create(:practice, organization: organization)
    render Views::Admin::Organizations::Edit.new(organization: organization)
    assert_select "form[action='#{admin_organization_path(organization)}'][method='post']"
  end
end
