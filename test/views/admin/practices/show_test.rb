require "test_helper"

class AdminPracticesShowTest < ActionView::TestCase
  it "renders attributes" do
    @practice = Practice.create!(organization: create(:organization), name: "My Practice")
    render template: "admin/practices/show"
    assert_includes rendered, "My Practice"
  end
end
