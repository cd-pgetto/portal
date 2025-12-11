require "rails_helper"

RSpec.describe "patients/show", type: :view do
  before(:each) { assign(:patient, create(:patient_with_practice_and_org)) }

  it "renders attributes in <p>" do
    render
  end
end
