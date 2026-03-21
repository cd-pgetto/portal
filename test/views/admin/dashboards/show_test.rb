require "test_helper"

class AdminDashboardShowTest < ActionView::TestCase
  it "renders the dashboard view" do
    render Views::Admin::Dashboards::Show.new
    assert_includes rendered, "Organizations"
    assert_select "a[href='#{admin_organizations_path}']"
    assert_includes rendered, "Identity Providers"
    assert_includes rendered, "Users"
    assert_includes rendered, "Practices"
  end
end
