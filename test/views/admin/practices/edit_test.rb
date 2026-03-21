require "test_helper"

class AdminPracticesEditTest < ActionView::TestCase
  it "renders the edit practice form" do
    practice = Practice.create!(organization: create(:organization), name: "My Practice")
    @practice = practice
    render partial: "admin/practices/form", locals: {practice: practice}
    assert_select "form[action='#{admin_practice_path(practice)}'][method='post']"
  end
end
