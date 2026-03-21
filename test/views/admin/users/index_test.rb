require "test_helper"

class AdminUsersIndexTest < ActionView::TestCase
  it "renders a list of users" do
    users = [create(:another_user), create(:another_user)]
    render Views::Admin::Users::Index.new(users: users)
    assert rendered.present?
  end
end
