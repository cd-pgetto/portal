require "test_helper"

class AdminUsersNewTest < ActionView::TestCase
  it "renders new user form" do
    @user = User.new
    render partial: "admin/users/form", locals: {user: User.new}
    assert_select "form[action='#{admin_users_path}'][method='post']"
  end
end
