require "test_helper"

class AdminOrganizationsNewTest < ActionView::TestCase
  it "renders new organization form" do
    render Views::Admin::Organizations::New.new(organization: Organization.new)
    assert_select "form[action='#{admin_organizations_path}'][method='post']"
    assert_select "form input[type='submit'][value='Create Organization']"
  end
end
