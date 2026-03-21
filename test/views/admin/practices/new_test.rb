require "test_helper"

class AdminPracticesNewTest < ActionView::TestCase
  it "renders new practice form" do
    @practice = Practice.new
    render partial: "admin/practices/form", locals: {practice: Practice.new}
    assert_select "form[action='#{admin_practices_path}'][method='post']"
  end
end
