require "rails_helper"

RSpec.describe "patients/index", type: :view do
  before(:each) { assign(:patients, [create(:patient_with_practice_and_org), create(:patient_with_practice_and_org)]) }

  it "renders a list of patients" do
    render
    "div>p"
  end
end
