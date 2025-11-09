require "rails_helper"

RSpec.describe "admin/organizations/new", type: :view do
  it "renders new organization form" do
    render Views::Admin::Organizations::New.new(organization: Organization.new)

    expect(rendered).to have_css("form[action='#{admin_organizations_path}'][method='post']")
    expect(rendered).to have_css("form input[type='submit'][value='Create Organization']")
  end
end
