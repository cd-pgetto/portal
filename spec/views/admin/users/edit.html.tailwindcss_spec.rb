require "rails_helper"

RSpec.describe "admin/users/edit", type: :view do
  let(:user) { create(:user) }

  before(:each) do
    assign(:user, user)
  end

  it "renders the edit user form" do
    render

    assert_select "form[action=?][method=?]", admin_user_path(user), "post" do
    end
  end
end
