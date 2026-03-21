require "test_helper"

class AdminUsersEditTest < ActionView::TestCase
  it "renders the edit user form" do
    user = create(:another_user)
    @user = user
    render partial: "admin/users/form", locals: {user: user}
    assert_select "form[action='#{admin_user_path(user)}'][method='post']"
  end
end
