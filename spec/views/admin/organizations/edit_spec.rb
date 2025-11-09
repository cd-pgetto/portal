require "rails_helper"

RSpec.describe "admin/organizations/edit", type: :view do
  let(:organization) { create(:org_with_domains_and_oauth_providers) }

  it "renders the edit admin organization form" do
    render Views::Admin::Organizations::Edit.new(organization: organization)

    assert_select "form[action=?][method=?]", admin_organization_path(organization), "post" do
    end
  end
end
