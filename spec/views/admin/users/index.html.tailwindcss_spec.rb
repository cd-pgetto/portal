require "rails_helper"

RSpec.describe "admin/users/index", type: :view do
  before(:each) do
    assign(:users, [create(:user), create(:another_user)])
  end

  it "renders a list of users" do
    render
    "div>p"
  end
end
