require "rails_helper"

RSpec.describe "practices/edit", type: :view do
  let(:practice) {
    Practice.create!(organization: create(:organization), name: "My Practice")
  }

  before(:each) do
    assign(:practice, practice)
  end

  it "renders the edit practice form" do
    render

    assert_select "form[action=?][method=?]", practice_path(practice), "post" do
    end
  end
end
