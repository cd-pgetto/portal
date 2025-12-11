require "rails_helper"

RSpec.describe "admin/practices/show", type: :view do
  before(:each) do
    assign(:practice, Practice.create!(organization: create(:organization), name: "My Practice"))
  end

  it "renders attributes in <p>" do
    render
  end
end
