require "test_helper"

class AdminUsersShowTest < ActionView::TestCase
  it "renders user attributes" do
    user = create(:another_user)
    @user = user
    render template: "admin/users/show"
    assert_includes rendered, "Edit this user"
  end
end
