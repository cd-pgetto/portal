require "rails_helper"

RSpec.describe "admin/practices/index", type: :view do
  before(:each) do
    assign(:practices, [
      Practice.create!(organization: create(:organization), name: "My Practice 1"),
      Practice.create!(organization: create(:organization), name: "My Practice 2")
    ])
  end

  it "renders a list of practices" do
    render
    cell_selector = "div>p"
  end
end
